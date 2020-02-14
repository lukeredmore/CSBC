if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const constants = require('./constants.json')
const admin = require('firebase-admin')
const daySchedule = require('./day-schedule.js')
const nodemailer = require('nodemailer')
const cors = require('cors') ({origin: true})
const privateFiles = require('./private-files.json')


//MARK: Methods for pass system
exports.toggleHandler = async (req, res) => {
  const dateStringComponents = new Date().toLocaleDateString('en-US', { 
    timeZone: "America/New_York",
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric' }
  ).split('/')
  const timeString = new Date().toLocaleTimeString('en-US', {timeZone: 'America/New_York'})
  const dateString = dateStringComponents[2] + "-" + dateStringComponents[0] + "-" + dateStringComponents[1]


  //Validate time of request
  const timeString24H = new Date().toLocaleTimeString('it-IT', {timeZone: 'America/New_York'})
  let daySched = await daySchedule.create()
  let allSchoolDays = Object.keys(daySched.highSchool)
  const hourOfDay = Number(timeString24H.split(':')[0])
    req.query.forceSign = "toggle" //COMMENT THIS OUT ONCE IT GOES LIVE!!
  if ((hourOfDay < 8 || hourOfDay > 14 || !allSchoolDays.includes(dateString)) && (req.query.forceSign === null || typeof req.query.forceSign === 'undefined')) {
    console.log("timeString24H: " + timeString24H)
    console.log("timeString: " + timeString)
    console.log("hour of day: " + hourOfDay)
    return res.status(400).send("Toggle requests only honored during the school day")
  }

  //Validate parameters
  const id = Number(req.query.studentIDNumber)
  if (isNaN(id) || id > 9999999999)
    return res.status(400).send("Invalid student ID number")


  //Get existing student data
  let currentStudentPassData = (await admin.database().ref('PassSystem/Students/' + id).once('value')).val()
  if (currentStudentPassData === null || typeof currentStudentPassData === 'undefined')
    return res.status(400).send("Student not found with ID number: " + id)


  //Move current location info to log
  if (typeof currentStudentPassData["log"] === 'undefined') { currentStudentPassData["log"] = [] }
  currentStudentPassData["log"].push({
    status: currentStudentPassData["currentStatus"],
    time: currentStudentPassData["timeOfStatusChange"]
  })


  //Get current time and location
  const timeOfStatusChange = (new Date()).toISOString()//dateString + " " + timeString
  let location = ""
  if (req.query.location !== null && typeof req.query.location !== 'undefined')
    location = " - " + req.query.location.replace("_", " ")

  //Update current data
  let forceSignToTest = ""
  if (req.query.forceSign !== null && typeof req.query.forceSign !== 'undefined')
    forceSignToTest = String(req.query.forceSign)

  if (forceSignToTest.toLowerCase().includes('in') || forceSignToTest.toLowerCase().includes('out')) {
    currentStudentPassData["currentStatus"] = "Signed " + forceSignToTest.replace(/^\w/, c => c.toUpperCase()) + location
  } else {
    const period = getCurrentPeriod()
    let studentAlreadySignedIntoThisPeriod = false
    for (var i = currentStudentPassData["log"].length - 1; i >= 0; i--) {
      const entry = currentStudentPassData["log"][i]
      let studentSignedIntoThisPeriod = entry.status.includes('Period ' + period)
      let thisPeriodWasToday = entry.time.split('T')[0] === timeOfStatusChange.split('T')[0]
      studentAlreadySignedIntoThisPeriod = studentSignedIntoThisPeriod && thisPeriodWasToday
      if (studentAlreadySignedIntoThisPeriod) { break }
    }

    if (studentAlreadySignedIntoThisPeriod || period === 0) {
      currentStudentPassData["currentStatus"] = (currentStudentPassData["currentStatus"].toLowerCase().includes("out") ? "Signed In" : "Signed Out") + location
    } else {
      currentStudentPassData["currentStatus"] = "Signed In To Period " + period + location
    }
  }
  currentStudentPassData["timeOfStatusChange"] = timeOfStatusChange


  //Update firebase
  await admin.database().ref('PassSystem/Students/' + id).set(currentStudentPassData, error => {
    if (error) {
      return res.status(400).send(error)
    } else {
      return res.status(200).json({
        "Database updated sucessfully for id": id,
        "New Pass Data": currentStudentPassData
      })
    }
  })
  return res.status(500)
}
exports.addHandler = async (req, res) => {
  const id = Number(req.query.studentIDNumber)
  const graduationYear = Number(req.query.graduationYear)
  const name = req.query.name.replace("_", " ")
  if (isNaN(id) || id > 9999999999 || isNaN(graduationYear) || graduationYear < 2000 || graduationYear > 5000 || name === null)
    return res.status(400).send("Invalid student parameters")
    
  let studentToAdd = (await admin.database().ref('PassSystem/Students/' + id).once('value')).val()
  if (studentToAdd !== null && typeof studentToAdd !== 'undefined')
    return res.status(400).send("This ID has already been added")

  studentToAdd = {
    name: name,
    graduationYear: graduationYear,
    timeOfStatusChange: (new Date()).toISOString(),
    currentStatus: "Signed In"
  }

  await admin.database().ref('PassSystem/Students').child(id).set(studentToAdd, error => {
    if (error)
      return res.status(500).send("Error: " + error)
    else
      return res.status(200).json(name + " with ID of " + id + " has successfully been added to the pass system.")
  })
  return res.status(500)
}
function getCurrentPeriod() {
  const dateString = (new Date()).toLocaleDateString('en-US', { 
    timeZone: "America/New_York",
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric',
    hour12: false
  }).split('/')
  let timeString = (new Date()).toLocaleTimeString('en-US', { 
    timeZone: "America/New_York",
    hour: '2-digit', 
    minute: '2-digit', 
    second: 'numeric',
  hour12: false 
  })
  let dateTimeString = dateString[2] + "-" + dateString[0] + "-" + dateString[1] + " " + timeString
  const currentDate = new Date(dateTimeString)

  for (var i = 1; i < constants.TIMES_OF_PERIOD_START.length; i++) {
    let lastBellDate = new Date(dateString + " " + constants.TIMES_OF_PERIOD_START[i-1])
    let nextBellDate = new Date(dateString + " " + constants.TIMES_OF_PERIOD_START[i])
    
    if (currentDate >= lastBellDate && currentDate < nextBellDate) {
      console.log("we are in period " + i + "\n")
      return i
    }
  }
  return 0
}


exports.checkForOutstandingStudents = async () => {
  let allStudentsDataObject = (await admin.database().ref('PassSystem/Students').once('value')).val()
  let allStudentsDataArray = Object.values(allStudentsDataObject)
  let outstandingStudents = []
  for (student of allStudentsDataArray) { 
    if (!student.currentStatus.toLowerCase().includes('out')) { continue }
    const minutesAbsent = (new Date() - new Date(student.timeOfStatusChange))/60000
    console.log(new Date())
    console.log(new Date(student.timeOfStatusChange))
    console.log(minutesAbsent)
    if (minutesAbsent >= 15 && minutesAbsent < 20) {
      outstandingStudents.push(student)
    } else {
      console.log("Student not outstanding " + JSON.stringify(student))
    }
  }

  console.log("\n\n")
  console.log(JSON.stringify(outstandingStudents))
  
  await notifyOfOutstandingStudents(outstandingStudents)
  await sendPeriodToDebug()
}
async function notifyOfOutstandingStudents(studentArray) {
  if (studentArray.length === 0) {
    console.log("No oustanding students")
    return
  }
  let outstandingStudentNames = []
  var body = "<p style='font-size: 16px;'>The following students have been out of class or unaccounted for for more than 15 minutes: <br/><br/>"
  for (student of studentArray) { 
    var gradeMap = createGradeMap()
    var gradeLevel = gradeMap[student.graduationYear]
    var lastLocation = student.currentStatus.split("- ")[1]
    var minutesAbsent = Math.round((new Date() - new Date(student.timeOfStatusChange))/6000)/10

    body += "<u>" + student.name +  " (Grade " + gradeLevel + ")</u><br/>"
    body += "<i>Time out: </i>" + minutesAbsent + " minutes <br/>"
    body += "<i>Signed out of: </i>" + lastLocation + "<br/><br/>"
    outstandingStudentNames.push(student.name)
  }
    
  body += "Please remind these students to sign back in when they return to class.<br/><hr><br/><i>This is an automated message. Please do not respond.</i></p>"

  let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: privateFiles.MAIL_CREDENTIALS.USERNAME,
      pass: privateFiles.MAIL_CREDENTIALS.PASSWORD
    }
  })

  let sendersList = (await admin.database().ref('PassSystem/NotifyWhenOutstanding').once('value')).val()
  sendersList = Object.values(sendersList).join(', ')
  

  const mailOptions = {
    from: "CSBC Mobile App" + '<' + privateFiles.MAIL_CREDENTIALS.USERNAME + '>',
    to: sendersList,
    subject: "**OUTSTANDING STUDENT ALERT**",
    html: body
  }

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log(error.toString())
    } else {
      console.log("Email successfully sent. Oustanding students: " + JSON.stringify(outstandingStudentNames))
    }  
  })
}
function createGradeMap() {
  var seniorsGradYear = Number(constants.LAST_DAY_OF_SCHOOL.split('/')[2])
  var gradeMap = {}
  for(var i = 12; i >= 7; i--) {
    gradeMap[seniorsGradYear] = i
    seniorsGradYear += 1
  }
  return gradeMap
}


async function sendPeriodToDebug() {
  let minutes = (new Date()).getMinutes()
  console.log((minutes) + "  and   " + (Math.floor(minutes / 10 % 10)))
  if (minutes % 2 !== 0 || (Math.floor(minutes / 10 % 10) % 2) !== 0) { return }


  let period = getCurrentPeriod()
  let alertNotif = { 
    notification: {
      title: "Current period testing",
      body: "The app says its now period " + period
    },
    android: {
      priority: "HIGH",
      ttl: 86400000,
      notification: { sound: "default" }
    },
    apns: { payload: { aps: {
      sound: "default"
    } } },
    condition: "('debugDevice' in topics)"
  }
  
  await admin.messaging().send(alertNotif)
    .then(response => {
      console.log('Successfully sent period message to debug: ', JSON.stringify(response))
      return
    })
    .catch(error => {
      console.log('Error sending message: ', error)
      return
    }) 
}