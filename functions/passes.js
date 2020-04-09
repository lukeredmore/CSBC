if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const constants = require('./constants.json')
const admin = require('firebase-admin')
const daySchedule = require('./day-schedule.js')
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

    const dateStringComponents = new Date()
      .toLocaleDateString('en-US', {
        timeZone: 'America/New_York',
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
      })
      .split('/')
    const dateString = dateStringComponents[2] + '-' + dateStringComponents[0] + '-' + dateStringComponents[1]

    const schoolToday = (
      await admin
        .database()
        .ref('DaySchedule/highSchool/' + dateString)
        .once('value')
    ).val()
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
    if (forceSign === 'in' || forceSign === 'out') 
      data.currentStatus = `Signed ${forceSign} - ${location}`
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
    try {
      await admin
        .database()
        .ref('PassSystem/Students/' + key)
        .set(data)
      return res.status(200).json({
        message: `Database updated sucessfully for ${data.name} (${id}): '${data.currentStatus}'`,
      })
    } catch (e) {
      return res.status(500).json({ message: e })
    }
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
    if (
      isNaN(graduationYear) ||
      graduationYear < Number(constants.LAST_DAY_OF_SCHOOL.split('/')[2]) ||
      graduationYear > Number(constants.LAST_DAY_OF_SCHOOL.split('/')[2]) + 6 ||
      !name
    ) {
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

    try {
      await admin.database().ref('PassSystem/Students').push(studentToAdd)
      return res.status(200).json({
        message: name + ' with ID of ' + idNumber + ' has successfully been added to the pass system.',
      })
    } catch (e) {
      return res.status(500).json({ message: e.toString() })
    }
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
    try {
      await admin
        .database()
        .ref('PassSystem/Students/' + studentToDelete[0])
        .remove()
      return res.status(200).json({
        message:
          studentToDelete[1].name +
          ' with IDs ' +
          JSON.stringify(studentToDelete[1].id) +
          ' has successfully been removed from the system.',
      })
    } catch (e) {
      return res.status(500).json({ message: e.toString() })
    }
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
  for (student of studentArray) {
    var gradeMap = createGradeMap()
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

  let sendersList = (await admin.database().ref('PassSystem/EmailWhenOutstanding').once('value')).val()
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
    admin
      .messaging()
      .send(notifObj)
      // eslint-disable-next-line no-loop-func
      .then(() => {
        console.log('Successfully notified of outstanding student ' + student.name + '.')
        return
      })
      // eslint-disable-next-line no-loop-func
      .catch(error => {
        console.log('Error notifying of outstanding student ' + student.name + ': ', error)
        return
      })
  }
}
function createGradeMap() {
  var seniorsGradYear = Number(constants.LAST_DAY_OF_SCHOOL.split('/')[2])
  var gradeMap = {}
  for (var i = 12; i >= 7; i--) {
    gradeMap[seniorsGradYear] = i
    seniorsGradYear += 1
  }
  return gradeMap
}

async function getAllStudents() {
  let allStudentsDataObject = (await admin.database().ref('PassSystem/Students').once('value')).val()
  return allStudentsDataObject ? Object.values(allStudentsDataObject) : []
}

async function getAllStudentsWithPushID() {
  let allStudentsDataObject = (await admin.database().ref('PassSystem/Students').once('value')).val()
  return allStudentsDataObject ? Object.entries(allStudentsDataObject) : []
}
