if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const constants = require('./constants.json')
const admin = require('firebase-admin')
const daySchedule = require('./day-schedule-and-alerts.js')


//MARK: Methods for pass system
exports.toggleHandler = async (req, res) => {
  const dateStringComponents = new Date().toLocaleDateString('en-US', { 
    timeZone: "America/New_York",
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric' }
  ).split('/')
  const timeString = new Date().toLocaleTimeString('en-US', {
    timeZone: 'America/New_York'
  })
  const dateString = dateStringComponents[2] + "-" + dateStringComponents[0] + "-" + dateStringComponents[1]

  //Validate time of request
  let daySched = await daySchedule.create()
  let allSchoolDays = Object.keys(daySched.highSchool)
  const hourOfDay = Number(timeString.split(':')[0])
  req.query.forceSign = "toggle" //COMMENT THIS OUT ONCE IT GOES LIVE!!
  if ((hourOfDay < 8 || hourOfDay > 15 || !allSchoolDays.includes(dateString)) && (req.query.forceSign === null || typeof req.query.forceSign === 'undefined'))
    return res.status(400).send("Toggle requests only honored during the school day")

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
  const timeOfStatusChange = dateString + " " + timeString
  let location = ""
  if (req.query.location !== null && typeof req.query.location !== 'undefined')
    location = " - " + req.query.location.replace("_", " ")

  //Update current data
  const hourAndMinuteAndSecondArray = timeOfStatusChange.split(' ')[1].split(':')
  const hourAndMinute = hourAndMinuteAndSecondArray[0] + ':' + hourAndMinuteAndSecondArray[1]
  if (req.query.forceSign.toLowerCase().includes('in') || req.query.forceSign.toLowerCase().includes('out')) {
    currentStudentPassData["currentStatus"] = "Signed " + req.query.forceSign.replace(/^\w/, c => c.toUpperCase())
  } else if (constants.TIMES_TO_FORCE_SIGN_IN.includes(hourAndMinute)) {
    currentStudentPassData["currentStatus"] = "Signed In" + location
  } else {
    currentStudentPassData["currentStatus"] = (currentStudentPassData["currentStatus"].toLowerCase().includes("out") ? "Signed In" : "Signed Out") + location
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


  const dateStringComponents = new Date().toLocaleDateString('en-US', { 
    timeZone: "America/New_York",
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric' 
  }).split('/')
  const timeString = new Date().toLocaleTimeString('en-US', {
    timeZone: "America/New_York"
  })
  const timeOfStatusChange = dateStringComponents[2] + "-" + dateStringComponents[0] + "-" + dateStringComponents[1] + " " + timeString

    
  let studentToAdd = (await admin.database().ref('PassSystem/Students/' + id).once('value')).val()
  if (studentToAdd !== null && typeof studentToAdd !== 'undefined')
    return res.status(400).send("This ID has already been added")

  studentToAdd = {
    name: name,
    graduationYear: graduationYear,
    timeOfStatusChange: timeOfStatusChange,
    currentStatus: "Signed In"
  }

  await admin.database().ref('PassSystem/Students').child(id).set(studentToAdd, error => {
    if (error)
      return res.status(400).send("Error: " + error)
    else
      return res.status(200).json(name + " with ID of " + id + " has successfully been added to the pass system.")
  })
  return res.status(500)
}