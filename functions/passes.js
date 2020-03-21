if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS =
    "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json"
}
const constants = require("./constants.json")
const admin = require("firebase-admin")
const daySchedule = require("./day-schedule.js")
const nodemailer = require("nodemailer")
const cors = require("cors")({ origin: true })
const privateFiles = require("./private-files.json")
const schedule = require('./schedule.js')

//MARK: Methods for pass system
exports.toggleHandler = async (req, res) => {
  const dateStringComponents = new Date()
    .toLocaleDateString("en-US", {
      timeZone: "America/New_York",
      day: "2-digit",
      month: "2-digit",
      year: "numeric"
    })
    .split("/")
  const timeString = new Date().toLocaleTimeString("en-US", {
    timeZone: "America/New_York"
  })
  const dateString =
    dateStringComponents[2] +
    "-" +
    dateStringComponents[0] +
    "-" +
    dateStringComponents[1]

  //Validate time of request
  const timeString24H = new Date().toLocaleTimeString("it-IT", {
    timeZone: "America/New_York"
  })
  let daySched = await daySchedule.create()
  let allSchoolDays = Object.keys(daySched.highSchool)
  const hourOfDay = Number(timeString24H.split(":")[0])
  req.query.forceSign = "toggle" //COMMENT THIS OUT ONCE IT GOES LIVE!!
  if (
    (hourOfDay < 8 || hourOfDay > 14 || !allSchoolDays.includes(dateString)) &&
    (req.query.forceSign === null || typeof req.query.forceSign === "undefined")
  ) {
    console.log("timeString24H: " + timeString24H)
    console.log("timeString: " + timeString)
    console.log("hour of day: " + hourOfDay)
    return res
      .status(400)
      .send("Toggle requests only honored during the school day")
  }

  //Validate parameters
  const id = Number(req.query.studentIDNumber)
  if (isNaN(id) || id > 9999999999)
    return res.status(400).send("Invalid student ID number")

  //Get existing student data
  let allStudents = await getAllStudentsWithPushID()
  let currentStudentPassDataArr = allStudents.filter(e => e[1].id.includes(id))
  if (currentStudentPassDataArr.length === 0)
    return res.status(400).send("Student not found with ID number: " + id)
    let currentStudentPassData = currentStudentPassDataArr[0][1]
    let currentStudentID = currentStudentPassDataArr[0][0]

  //Move current location info to log
  if (typeof currentStudentPassData["log"] === "undefined") {
    currentStudentPassData["log"] = []
  }
  currentStudentPassData["log"].push({
    status: currentStudentPassData["currentStatus"],
    time: currentStudentPassData["timeOfStatusChange"]
  })

  //Get current time and location
  const timeOfStatusChange = new Date().toISOString() //dateString + " " + timeString
  let location = ""
  if (req.query.location !== null && typeof req.query.location !== "undefined")
    location = " - " + req.query.location.replace("_", " ")

  //Update current data
  let forceSignToTest = ""
  if (
    req.query.forceSign !== null &&
    typeof req.query.forceSign !== "undefined"
  )
    forceSignToTest = String(req.query.forceSign)

  if (
    forceSignToTest.toLowerCase().includes("in") ||
    forceSignToTest.toLowerCase().includes("out")
  ) {
    currentStudentPassData["currentStatus"] =
      "Signed " +
      forceSignToTest.replace(/^\w/, c => c.toUpperCase()) +
      location
  } else {
    const period = await schedule.getCurrentPeriod()
    let studentAlreadySignedIntoThisPeriod = false
    for (var i = currentStudentPassData["log"].length - 1; i >= 0; i--) {
      const entry = currentStudentPassData["log"][i]
      let studentSignedIntoThisPeriod = entry.status.includes(
        "Period " + period
      )
      let thisPeriodWasToday =
        entry.time.split("T")[0] === timeOfStatusChange.split("T")[0]
      studentAlreadySignedIntoThisPeriod =
        studentSignedIntoThisPeriod && thisPeriodWasToday
      if (studentAlreadySignedIntoThisPeriod) {
        break
      }
    }

    if (studentAlreadySignedIntoThisPeriod || period === 0) {
      currentStudentPassData["currentStatus"] =
        (currentStudentPassData["currentStatus"].toLowerCase().includes("out")
          ? "Signed In"
          : "Signed Out") + location
    } else {
      currentStudentPassData["currentStatus"] =
        "Signed In To Period " + period + location
    }
  }
  currentStudentPassData["timeOfStatusChange"] = timeOfStatusChange

  //Update firebase
  try {
    await admin.database().ref("PassSystem/Students/" + currentStudentID).set(currentStudentPassData)
    return res.status(200).json({
      "Database updated sucessfully for id": id,
      "New Pass Data": currentStudentPassData
    })
  } catch (e) {
    return res.status(500).send(e)
  }
}
exports.addHandler = async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*")
  res.set("Access-Control-Allow-Methods", "GET, POST")
  res.set("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
  res.set("Access-Control-Max-Age", "86400")

  const id = Number(req.query.studentIDNumber)
  const graduationYear = Number(req.query.graduationYear)
  const name = req.query.name ? req.query.name.replace("_", " ") : null
  if (
    isNaN(id) ||
    isNaN(graduationYear) ||
    graduationYear < Number(constants.LAST_DAY_OF_SCHOOL.split("/")[2]) ||
    graduationYear > Number(constants.LAST_DAY_OF_SCHOOL.split("/")[2]) + 6 ||
    !name
  ) {
    res.status(400).json({ error: "Invalid student parameters." })
    return 
  }


    let allStudentsArray = await getAllStudents()
    let existingStudentArr = allStudentsArray.filter(e => e.id.includes(id))
    if (existingStudentArr.length > 0) {
      res.status(400).json({error: "This ID has already been assigned to " + existingStudentArr[0].name + "."})
      return
    }

  studentToAdd = {
    name: name,
    graduationYear: graduationYear,
    id: [id],
    timeOfStatusChange: new Date().toISOString(),
    currentStatus: "Signed In"
  }

  try {
    await admin.database().ref("PassSystem/Students").push(studentToAdd)
    res.status(200).json({
      message: name + " with ID of " + id + " has successfully been added to the pass system.", 
      status: 200
    })
  } catch (e) {
    res.status(500).json({ error: e })
  }
}
exports.deleteHandler = async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*")
  res.set("Access-Control-Allow-Methods", "GET, POST")
  res.set(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  )
  res.set("Access-Control-Max-Age", "86400")

  //Find element to delete
  let allStudentsDataArray = await getAllStudentsWithPushID()
  const studentToDelete = allStudentsDataArray.find(e => e[1].id.includes(Number(req.query.studentIDNumber)))
  
  //Ensure element exists
  if (!studentToDelete)
    return res.status(400).json({ error: "ID " + req.query.studentIDNumber + " does not exist." })

  //Remove element from Firebase  
  try {
    await admin.database().ref("PassSystem/Students/" + studentToDelete[0]).remove()
    return res.status(200).json({
      error: null,
      message:
        allStudentsDataArray[0][1].name +
        " with ID " +
        req.query.studentIDNumber +
        " has successfully been removed from the system."
    })
  } catch (e) {
    return res.status(500).json({ error: e })
  }
}

exports.checkForOutstandingStudents = async () => {
  let allStudentsDataArray = await getAllStudents()
  let outstandingStudents = []
  for (student of allStudentsDataArray) {
    if (!student.currentStatus.toLowerCase().includes("out")) {
      continue
    }
    const minutesAbsent =
      (new Date() - new Date(student.timeOfStatusChange)) / 60000
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
}
async function notifyOfOutstandingStudents(studentArray) {
  if (studentArray.length === 0) {
    console.log("No oustanding students")
    return
  }
  let outstandingStudentNames = []
  var body =
    "<p style='font-size: 16px;'>The following students have been out of class or unaccounted for for more than 15 minutes: <br/><br/>"
  for (student of studentArray) {
    var gradeMap = createGradeMap()
    var gradeLevel = gradeMap[student.graduationYear]
    var lastLocation = student.currentStatus.split("- ")[1]
    var minutesAbsent =
      Math.round((new Date() - new Date(student.timeOfStatusChange)) / 6000) /
      10

    body += "<u>" + student.name + " (Grade " + gradeLevel + ")</u><br/>"
    body += "<i>Time out: </i>" + minutesAbsent + " minutes <br/>"
    body += "<i>Signed out of: </i>" + lastLocation + "<br/><br/>"
    outstandingStudentNames.push(student.name)
  }

  body +=
    "Please remind these students to sign back in when they return to class.<br/><hr><br/><i>This is an automated message. Please do not respond.</i></p>"

  let transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: privateFiles.MAIL_CREDENTIALS.USERNAME,
      pass: privateFiles.MAIL_CREDENTIALS.PASSWORD
    }
  })

  let sendersList = (
    await admin
      .database()
      .ref("PassSystem/NotifyWhenOutstanding")
      .once("value")
  ).val()
  sendersList = Object.values(sendersList).join(", ")

  const mailOptions = {
    from:
      "CSBC Mobile App" + "<" + privateFiles.MAIL_CREDENTIALS.USERNAME + ">",
    to: sendersList,
    subject: "**OUTSTANDING STUDENT ALERT**",
    html: body
  }

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log(error.toString())
    } else {
      console.log(
        "Email successfully sent. Oustanding students: " +
          JSON.stringify(outstandingStudentNames)
      )
    }
  })
}
function createGradeMap() {
  var seniorsGradYear = Number(constants.LAST_DAY_OF_SCHOOL.split("/")[2])
  var gradeMap = {}
  for (var i = 12; i >= 7; i--) {
    gradeMap[seniorsGradYear] = i
    seniorsGradYear += 1
  }
  return gradeMap
}

async function getAllStudents() {
  let allStudentsDataObject = (
    await admin
      .database()
      .ref("PassSystem/Students")
      .once("value")
  ).val()
  return allStudentsDataObject ? Object.values(allStudentsDataObject) : []
}

async function getAllStudentsWithPushID() {
  let allStudentsDataObject = (
    await admin
      .database()
      .ref("PassSystem/Students")
      .once("value")
  ).val()
  return allStudentsDataObject ? Object.entries(allStudentsDataObject) : []
}