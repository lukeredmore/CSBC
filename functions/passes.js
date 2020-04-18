if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const firebase = require('./firebase')
const nodemailer = require('nodemailer')
const cors = require('cors')({ origin: true })
const privateFiles = require('./private-files.json')
const schedule = require('./schedule.js')
const notifications = require('./notifications')
const authentication = require('./authentication.js')

/*PASS SYSTEM GCF EXPORTS*/
exports.toggleHandler = async (req, res) => {
  cors(req, res, async () => {
    const unauthenticated = await authentication.authenticateRequest(req.headers, ['toggleAccess', 'dashboardAccess'])
    if (unauthenticated) return res.status(403).json({ message: unauthenticated })

    const dateString = firebase.getDatabaseReadableDateString(new Date())
    const schoolToday = await firebase.getDataFromRef('DaySchedule/highSchool/' + dateString)
    const period = await schedule.getCurrentPeriod()

    const { id, location, forceSign } = req.body

    if ((period === 0 || !schoolToday) && !forceSign)
      return res.status(400).json({ message: 'Toggle requests only honored during the school day' })

    //Validate parameters
    if (!id || !location) return res.status(400).json({ message: 'Invalid parameters' })

    //Get existing student data
    let allStudents = await getAllStudentsWithPushID()
    let currentStudentPassEntry = allStudents.find(e => e[1].id.includes(id))
    if (!currentStudentPassEntry) return res.status(400).json({ message: 'Student not found with ID number: ' + id })
    let [key, data] = currentStudentPassEntry

    //Move current location info to log
    if (!data.log) data.log = []
    data.log.push({
      status: data.currentStatus,
      time: data.timeOfStatusChange,
    })

    //Get current time and location
    const timeOfStatusChange = new Date().toISOString()
    if (forceSign === 'in' || forceSign === 'out') data.currentStatus = `Signed ${forceSign} - ${location}`
    else {
      let studentAlreadySignedIntoThisPeriod = data.log.find(e => {
        console.log(e)
        return e.time.includes(timeOfStatusChange.split('T')[0]) && e.status.includes(`Period ${period}`)
      })

      if (studentAlreadySignedIntoThisPeriod || period === 0)
        data.currentStatus = (data.currentStatus.includes('Signed Out') ? 'Signed In' : 'Signed Out') + ` - ${location}`
      else data.currentStatus = `Signed In To Period ${period} - ${location}`
    }
    data.timeOfStatusChange = timeOfStatusChange

    //Update firebase
    let updateSuccess = await firebase.writeToRef('PassSystem/Students/' + key, data)
    if (!updateSuccess)
      return res.status(500).json({ message: 'An unknown error occurred and the user was not updated' })

    return res
      .status(200)
      .json({ message: `Database updated sucessfully for ${data.name} (${id}): '${data.currentStatus}'` })
  })
}
exports.addHandler = async (req, res) => {
  cors(req, res, async () => {
    const unauthenticated = await authentication.authenticateRequest(req.headers, ['dashboardAccess'])
    if (unauthenticated) return res.status(403).json({ message: unauthenticated })

    console.log(req.body)
    let { idNumber, name, graduationYear } = req.body
    graduationYear = Number(graduationYear)
    name = name ? name.replace('_', ' ') : null
    const ldocString = await firebase.getDataFromRef('Dates/endDate')
    const ldoc = Number(ldocString.split('-')[0])
    if (isNaN(graduationYear) || graduationYear < ldoc || graduationYear > ldoc + 6 || !name) {
      return res.status(400).json({ message: 'Invalid student parameters.' })
    }

    let allStudentsArray = await getAllStudents()
    let existingStudentArr = allStudentsArray.filter(e => e.id.includes(idNumber))
    if (existingStudentArr.length > 0) {
      return res
        .status(400)
        .json({ message: 'This ID has already been assigned to ' + existingStudentArr[0].name + '.' })
    }

    studentToAdd = {
      name: name,
      graduationYear: graduationYear,
      id: [idNumber],
      timeOfStatusChange: new Date().toISOString(),
      currentStatus: 'Signed In',
    }

    let databaseUpdated = await firebase.pushToRef('PassSystem/Students', studentToAdd)
    if (!databaseUpdated)
      return res.status(500).json({ message: 'An unknown error occurred and the database was not updated' })

    return res
      .status(200)
      .json({ message: name + ' with ID of ' + idNumber + ' has successfully been added to the pass system.' })
  })
}
exports.deleteHandler = async (req, res) => {
  cors(req, res, async () => {
    const unauthenticated = await authentication.authenticateRequest(req.headers, ['dashboardAccess'])
    if (unauthenticated) return res.status(403).json({ message: unauthenticated })

    //Find element to delete
    const idOfStudentToDelete = req.query.studentIDNumber
    let allStudentsDataArray = await getAllStudentsWithPushID()
    const studentToDelete = allStudentsDataArray.find(e => e[1].id.includes(idOfStudentToDelete))

    //Ensure element exists
    if (!studentToDelete)
      return res.status(400).json({ message: 'ID ' + req.query.studentIDNumber + ' does not exist.' })

    //Remove element from Firebase
    let studentRemoved = await firebase.removeAtRef('PassSystem/Students/' + studentToDelete[0])
    if (!studentRemoved)
      return res.status(500).json({ message: 'An unknown error occured and the student was not removed' })

    return res.status(200).json({
      message:
        studentToDelete[1].name +
        ' with IDs ' +
        JSON.stringify(studentToDelete[1].id) +
        ' has successfully been removed from the system.',
    })
  })
}
/*END OF GCF EXPORTS*/

exports.checkForOutstandingStudents = async () => {
  let allStudentsDataArray = await getAllStudents()
  let outstandingStudents = allStudentsDataArray.filter(student => {
    if (student.currentStatus.toLowerCase().includes('signed in')) return false
    const minutesAbsent = (new Date() - new Date(student.timeOfStatusChange)) / 60000
    if (minutesAbsent < 15 || minutesAbsent >= 20) return false
    else return true
  })

  if (outstandingStudents.length === 0) {
    console.log('No oustanding students')
    return
  }
  await emailOutstandingStudents(outstandingStudents)
  await notifyOutstandingStudents(outstandingStudents)
}
async function emailOutstandingStudents(studentArray) {
  let outstandingStudentNames = []
  var body =
    "<p style='font-size: 16px;'>The following students have been out of class or unaccounted for for more than 15 minutes: <br/><br/>"
  const ldocString = await firebase.getDataFromRef('Dates/endDate')
  const ldoc = Number(ldocString.split('-')[0])
  for (student of studentArray) {
    var gradeMap = createGradeMap(ldoc)
    var gradeLevel = gradeMap[student.graduationYear]
    var lastLocation = student.currentStatus.split('- ')[1]
    var minutesAbsent = Math.round((new Date() - new Date(student.timeOfStatusChange)) / 6000) / 10

    body += '<u>' + student.name + ' (Grade ' + gradeLevel + ')</u><br/>'
    body += '<i>Time out: </i>' + minutesAbsent + ' minutes <br/>'
    body += '<i>Signed out of: </i>' + lastLocation + '<br/><br/>'
    outstandingStudentNames.push(student.name)
  }

  body +=
    'Please remind these students to sign back in when they return to class.<br/><hr><br/><i>This is an automated message. Please do not respond.</i></p>'

  let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: privateFiles.MAIL_CREDENTIALS.USERNAME,
      pass: privateFiles.MAIL_CREDENTIALS.PASSWORD,
    },
  })

  let sendersList = await firebase.getDataFromRef('PassSystem/EmailWhenOutstanding')
  sendersList = Object.values(sendersList).join(', ')

  const mailOptions = {
    from: 'CSBC Mobile App' + '<' + privateFiles.MAIL_CREDENTIALS.USERNAME + '>',
    to: sendersList,
    subject: '**OUTSTANDING STUDENT ALERT**',
    html: body,
  }

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log(error.toString())
    } else {
      console.log('Email successfully sent. Oustanding students: ' + JSON.stringify(outstandingStudentNames))
    }
  })
}
async function notifyOutstandingStudents(studentArray) {
  for (student of studentArray) {
    const minutesAbsent = Math.round((new Date() - new Date(student.timeOfStatusChange)) / 6000) / 10
    const lastLocation = student.currentStatus.split('- ')[1]
    const body = `${student.name} - ${minutesAbsent} min. (${lastLocation})`
    let notifObj = notifications.createNotificationObject(
      'Outstanding Student Alert',
      body,
      "('notifyOutstanding' in topics)"
    )
    notifications.sendNotification(notifObj)
  }
}
function createGradeMap(gradYear) {
  var seniorsGradYear = gradYear
  var gradeMap = {}
  for (var i = 12; i >= 7; i--) {
    gradeMap[seniorsGradYear] = i
    seniorsGradYear += 1
  }
  return gradeMap
}

async function getAllStudents() {
  let allStudentsDataObject = await firebase.getDataFromRef('PassSystem/Students')
  return allStudentsDataObject ? Object.values(allStudentsDataObject) : []
}

async function getAllStudentsWithPushID() {
  let allStudentsDataObject = await firebase.getDataFromRef('PassSystem/Students')
  return allStudentsDataObject ? Object.entries(allStudentsDataObject) : []
}
