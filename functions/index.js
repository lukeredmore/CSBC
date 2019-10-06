const functions = require('firebase-functions')
const puppeteer = require('puppeteer')
const cheerio = require('cheerio')
var serviceAccount = require("./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json")
if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json"
}
const admin = require('firebase-admin')
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://csbcprod.firebaseio.com"
})

//Scrape calendar events for the next two months from CSBCSaints.org and parses it to a JSON array
const opts = {memory: '2GB', timeoutSeconds: 60}
exports.autoUpdateEvents = functions.runWith(opts)
  .region('us-east4')
  .pubsub.schedule('25 * * * *')
  .timeZone('America/New_York')
  .onRun(async (context) => {

    let hourOfDay = Number(new Date().toLocaleTimeString('en-US', {
      timeZone: "America/New_York"
    }).split(':')[0])
    if (hourOfDay === 15) {
      const daySched = await daySchedule()
      const schoolDaysList = Object.keys(daySched.highSchool)
      const dateStringComponents = new Date().toLocaleDateString('en-US', { 
        day: '2-digit', 
        month: '2-digit', 
        year: 'numeric' }
      ).split('/')
      const dateStringForSignIn = dateStringComponents[2] + "-" + dateStringComponents[0] + "-" + dateStringComponents[1]
      if (schoolDaysList.includes(dateStringForSignIn)) {
        await signAllStudentsIn()
      } else { console.log("It's 3:00 PM, but not a school day, so no need to sign in outstandings")}
    } else { console.log("Not signing in outstanding right now")}

    let html1 = ""
    let html2 = ""

    const browser = await puppeteer.launch({
      args: ['--no-sandbox']
    })
    try {
        const page = await browser.newPage()
        await page.goto('https://www.csbcsaints.org/calendar', { waitUntil: 'domcontentloaded' })
        html1 = await page.content()
        const nextButton = await page.$("#evcal_next")
        await nextButton.click()
        await page.waitFor(() => document.querySelector('#evcal_list').getAttribute('style') === "display: block;")
        html2 = await page.content()
    } catch (e) {
      console.log(e)
    }

    const responseJSON = parseHTMLForEvents(html1).concat(parseHTMLForEvents(html2))


    const dateString = new Date().toLocaleDateString('en-US', { 
      timeZone: "America/New_York",
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric' }
    )
    const timeString = new Date().toLocaleTimeString('en-US', {
      timeZone: "America/New_York"
    })
    const databaseJSON = {
        eventsArray: responseJSON,
        eventsArrayTime: dateString + " " + timeString
    };

    await admin.database().ref('Calendars').set(databaseJSON, error => {
        if (error) {
            console.log("Error updating database: " + JSON.stringifiy(error))
        } else {
            console.log("Database updated successfully with Calendar data")
        }
    })
    await browser.close()
    return null;
})
function parseHTMLForEvents(html) {
    const dateAbbrv = {
      "jan": "01",
      "feb": "02",
      "mar": "03",
      "apr": "04",
      "may": "05",
      "jun": "06",
      "jul": "07",
      "aug": "08",
      "sep": "09",
      "oct": "10",
      "nov": "11",
      "dec": "12"
    }
    var data = []
    const $ = cheerio.load(html)
    $('#evcal_list .eventon_list_event').each((i, elem) => {
      const cell = $(elem).find('.desc_trig_outter').first()
  
      let titleString = cell.find('.evcal_event_title').first().text()
  
      let dateString = cell.find('.evo_start .date').first().text()
  
      let timeString = cell.find('.evcal_time').first().text().toUpperCase()
      if (timeString.includes("(ALL DAY")) {
        timeString = "All Day"
      }
  
      let schoolsString = cell.find('.ett1').first().text().replace("Schools:", "")
        
      if (titleString !== "" && dateString !== "") {
        data.push({
          title : titleString,
          date : cell.find('.evcal_cblock').attr('data-syr') + "-" + dateAbbrv[cell.find('.evo_start .month').first().text()] + "-" + dateString,
          time : timeString,
          schools : schoolsString
        })
      }
      
    })
    return data
}

async function daySchedule() {
  let snapshot = await admin.database().ref('SnowDays').once('value')
  const startDateString = "09/04/2019" //first day of school
  const endDateString = "06/19/2020" //last day of school
  var dateDayDict = {
    highSchool : {},
    elementarySchool : {}
  }
  
  const noSchoolDateStrings = ["10/11/2019", "10/14/2019", "11/05/2019", "11/11/2019", "11/27/2019", "11/28/2019", "11/29/2019", "12/23/2019", "12/24/2019", "12/25/2019", "12/26/2019", "12/27/2019", "12/30/2019", "12/31/2019", "01/01/2020", "01/20/2020", "02/14/2020", "02/17/2020", "03/12/2020", "03/13/2020", "04/06/2020", "04/07/2020", "04/08/2020", "04/09/2020", "04/10/2020", "04/13/2020", "05/21/2020", "05/22/2020", "05/25/2020"]
  const noElementarySchoolDateStrings = ["11/22/2019"]
  const noHighSchoolDateStrings = ["09/13/2019", "01/21/2020", "01/22/2020", "01/23/2020", "01/24/2020", "06/17/2020", "06/18/2020", "06/19/2020"]
  const snowDateStrings = Object.values(snapshot.val())

  var restrictedDatesForHS = []
  var restrictedDatesForES = []
  var restrictedDatesForHSStrings = []
  var restrictedDatesForESStrings = []
  
  var date = new Date(startDateString)
  const endDate = new Date(endDateString)
      
  //print("pushing no school and snow days")
  for (dateString of noSchoolDateStrings + snowDateStrings) {
    restrictedDatesForHS.push(new Date(dateString))
    restrictedDatesForHSStrings.push(dateString)
    restrictedDatesForES.push(new Date(dateString))
    restrictedDatesForESStrings.push(dateString)
  }
  //print("pushing exam dates")
  for (dateString of noHighSchoolDateStrings) {
    restrictedDatesForHS.push(new Date(dateString))
    restrictedDatesForHSStrings.push(dateString)
  }
  //print("pushing ptc dates")
  for (dateString of noElementarySchoolDateStrings) {
    restrictedDatesForES.push(new Date(dateString))
    restrictedDatesForESStrings.push(dateString)
  }
  var hsDay = 1
  var esDay = 1
  while (date <= endDate) {
    if (date.getDay() !== 0 && date.getDay() !== 6) { //if its a weekday
      let dateString = date.toLocaleDateString('en-US', { 
        day: '2-digit', 
        month: '2-digit', 
        year: 'numeric' }
      )
      let dateStringComponents = dateString.split('/')
      let dateToAddToDict = dateStringComponents[2] + "-" + dateStringComponents[0] + "-" + dateStringComponents[1]
      if (!restrictedDatesForHSStrings.includes(dateString)) {
        dateDayDict.highSchool[dateToAddToDict] = hsDay
        hsDay = hsDay <= 5 ? hsDay + 1 : 1
      }
      if (!restrictedDatesForESStrings.includes(dateString)) {
        dateDayDict.elementarySchool[dateToAddToDict] = esDay
        esDay = esDay <= 5 ? esDay + 1 : 1
      }
    }
    date.setDate(date.getDate() + 1);
  }
  return dateDayDict      
}
async function createAndSendDayNotification(sendingForReal = true) {
  let todaysDateStringComponents = new Date().toLocaleDateString('en-US', {
    timeZone: "America/New_York",
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).split('/')
  let todaysDateString = todaysDateStringComponents[2] + "-" + todaysDateStringComponents[0] + "-" + todaysDateStringComponents[1]
  const dateString = new Date().toLocaleDateString('en-US', { 
    timeZone: "America/New_York",
    day: '2-digit', 
    month: '2-digit', 
    year: 'numeric' }
  )
  const timeString = new Date().toLocaleTimeString('en-US', {
    timeZone: "America/New_York"
  })
  console.log(dateString + " " + timeString)
  let daySched = await daySchedule()
  console.log(JSON.stringify(daySched))
  console.log(todaysDateString)
  const hsDay = daySched.highSchool[todaysDateString]
  const esDay = daySched.elementarySchool[todaysDateString]
  console.log("hsDay: " + hsDay)
  console.log("esDay: " + esDay)
  const hsDayExists = hsDay !== null && typeof hsDay !== 'undefined'
  const esDayExists = esDay !== null && typeof esDay !== 'undefined'
  let messagesToSend = []

  if (hsDayExists) {
    messagesToSend.push({ 
      //Just HS
      notification: {
        title: "Good Morning!",
        body: "Today is Day " + hsDay + " at Seton"
      },
      android: {
        priority: "HIGH",
        ttl: 86400000,
        notification: { sound: "default" }
      },
      apns: { payload: { aps: {
        sound: "default"
      } } },
      condition: "!('notReceivingNotifications' in topics) && ('setonNotifications' in topics && !('johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics))",
    })
  }
  if (esDayExists) {
    messagesToSend.push({ 
      //Just ES
      notification: {
        title: "Good Morning!",
        body: "Today is Day " + esDay + " at St. John's, St. James, and All Saints"
      },
      android: {
        priority: "HIGH",
        ttl: 86400000,
        notification: { sound: "default" }
      },
      apns: { payload: { aps: {
        sound: "default"
      } } },
      condition: "!('notReceivingNotifications' in topics) && (!('setonNotifications' in topics) && ('johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics))",
    })
  }
  if (hsDayExists || esDayExists) {
    const hsString = hsDayExists ? "Today is Day " + hsDay + " at Seton, " : "There is no school at Seton today, "
    const esString = esDayExists ? "and today is Day " + esDay + " at the elementary schools." : "and there is no school at the elementary schools."

    messagesToSend.push({ 
      //Both HS and ES
      notification: {
        title: "Good Morning!",
        body: hsString + esString
      },
      android: {
        priority: "HIGH",
        ttl: 86400000,
        notification: { sound: "default" }
      },
      apns: { payload: { aps: {
        sound: "default"
      } } },
      condition: "(!('notReceivingNotifications' in topics) && ('setonNotifications' in topics && ('johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics)))",
    })
  }

  if (sendingForReal & (hsDayExists || esDayExists)) {
    admin.messaging().sendAll(messagesToSend)
    .then((response) => {
      console.log('Successfully sent day notification:', JSON.stringify(response))
      return null
    })
    .catch((error) => {
      console.log('Error sending message:', error)
      return null
    })
  } else {
    console.log("Did not send day notification, as there was no school today, or have been overridden")
  }
  return
}
//Sends day schedule notifications every morning
exports.scheduledDayScheduleNotifications = functions
  .region('us-east4')
  .pubsub.schedule('00 07 * * *').timeZone('America/New_York')
  .onRun((context) => {
    const manuallyStopped = false
    if (manuallyStopped === false) {
      createAndSendDayNotification()
    }
    return null;
})



//MARK: Snow day methods
exports.autoUpdateDayScheduleAndCheckForAlerts = functions
  .region('us-east4')
  .pubsub.schedule('every 5 minutes')
  .timeZone('America/New_York')
  .onRun(async (context) => {

  let response = await checkForAlerts()
  console.log(JSON.stringify(response))

  let daySched = await daySchedule()
  await admin.database().ref('DaySchedule').set(daySched, error=> {
    if (error) {
      console.log("Error updating database: " + JSON.stringifiy(error))
      return //res.status(500).send("Error updating database: " + JSON.stringifiy(error))
    } else {
      console.log("Database updated successfully with Day Schedule data")
      return //res.status(200).send("Database updated successfully with Calendar data")
    }
  })
})

async function checkForAlerts() {
  //Get alert message and add it to firebase
  let alertMessage = "nil"
  /* DISABLE UNTIL AFTER FIRST SNOW DAY
  alertMessage = await checkForAlertFromCSBC()
  if (typeof alertMessage === 'undefined' || alertMessage === null) {
    alertMessage = await checkForAlertFromWBNG()
  }
  */
  let snapshot = await admin.database().ref('BannerAlertOverride').once('value')
  let bannerAlertOverride = snapshot.val()
  if (bannerAlertOverride === false) {
    await admin.database().ref('BannerAlertMessage').set(alertMessage) }

  //Check if message calls for snow day today
  if (alertMessage.toLowerCase().includes('closed') && alertMessage.toLowerCase().includes('today')) {
    const dateString = new Date().toLocaleDateString('en-US', { 
      timeZone: "America/New_York",
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric' }
    )
    let snapshot = await admin.database().ref('SnowDays').once('value')
    let snowDays = Objects.values(snapshot.val())

    //Runs if snow day hasn't been found before
    if (!snowDays.includes(dateString)) {
      snowDays.push(dateString)
      await admin.database().ref('SnowDyas').set(snowDays, error=> {
        if (error) {
          console.log("Error updating database: " + JSON.stringifiy(error))
        } else {
          console.log("Database updated successfully with new snow day")
        }
      })
      let snowDayAlertPayload = {
        notification: {
          title: "Cancellation Alert",
          body: "Due to inclement weather, the Catholic Schools of Broome County will be closed today."
        },
        android: {
          priority: "HIGH",
          ttl: 86400000,
          notification: { sound: "default" }
        },
        apns: { payload: { aps: {
          sound: "default"
        } } },
        condition: "'appuser' in topics || 'setonNotifications' in topics || 'johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics",
      }
      await admin.messaging().send(snowDayAlertPayload)
        .then((response) => {
        console.log('Successfully sent day notification:', JSON.stringify(response))
        return {
          alertMessageText: alertMessage,
          firstTimeFindingSnowDay: true,
          snowDayNotificationSucessfullySent: true,
        }
      })
        .catch((error) => {
        console.log('Error sending message:', error)
        return {
          alertMessageText: alertMessage,
          firstTimeFindingSnowDay: true,
          snowDayNotificationSucessfullySent: false,
          snowDayNotificationSucessfullySentError: JSON.stringify(error)
        }
      })

    } else {
      return {
        alertMessageText: alertMessage,
        firstTimeFindingSnowDay: false,
        snowDayNotificationSucessfullySent: false
      }
    }
    
  }
  
  return {
    alertMessageText: alertMessage,
    snowDayTodayWasFound: false
  }
}

async function checkForAlertFromCSBC() {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox']
  })
  try {
      const page = await browser.newPage()
      await page.goto('https://www.csbcsaints.org', { waitUntil: 'domcontentloaded' })
      let alertMessage = await page.$eval('strong', el => el.textContent)
      browser.close()
      return alertMessage
  } catch (e) {
    console.log("Checking for alert from CSBC website failed with error: " + e)
    browser.close()
    return null
  }
}

async function checkForAlertFromWBNG() {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox']
  })
  try {
      const page = await browser.newPage()
      await page.goto('https://www.csbcsaints.org', { waitUntil: 'domcontentloaded' })
      let alertMessage = await page.$eval('p', el => el.textContent)
      browser.close()
      return alertMessage
  } catch (e) {
    console.log("Checking for alert from WBNG failed with error: " + e)
    browser.close()
    return null
  }
}







//MARK: Methods for Alexa
/*
Parameters
date: date in yyyy-MM-dd format
school: 0 (elementary school) or 1 (high school)

Return
Day of cycle, if exists, or nothing if no school
*/
exports.getDayForDate = functions
  .region('us-east4')
  .https.onRequest(async (req, res) => {
    let date = req.query.date
    let school = Number(req.query.school)

    console.log("School requested is: " + school)
    console.log("Date requested is: " + date)
    let daySched = await daySchedule()
    if (school === 1) {
      return res.status(200).json(daySched.highSchool[date])
    } else if (school === 0) {
      return res.status(200).json(daySched.elementarySchool[date])
    } else {
      return res.status(200).json("Invalid request")
    }
  })







//MARK: Methods for pass system
exports.toggleStudentPassStatus = functions
  .region('us-east4')
  .runWith(opts).https.onRequest(async (req, res) => {
    let dateStringComponents = new Date().toLocaleDateString('en-US', { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric' }
    ).split('/')
    let timeString = new Date().toLocaleTimeString('en-US', {
      timeZone: 'America/New_York'
    })
    let dateString = dateStringComponents[2] + "-" + dateStringComponents[0] + "-" + dateStringComponents[1]

    //Validate time of request
    let daySched = await daySchedule()
    let allSchoolDays = Object.keys(daySched.highSchool)
    const hourOfDay = Number(timeString.split(':')[0])
    if ((hourOfDay < 8 || hourOfDay > 15 || !allSchoolDays.includes(dateString)) && (req.query.forceSign === null || typeof req.query.forceSign === 'undefined')) {
      return res.status(400).json("Toggle requests only honored during the school day")
    }


    const id = Number(req.query.studentIDNumber)
    if (isNaN(id) || id > 9999999999) {
      return res.status(400).json("Invalid student ID number")
    }

    const snapshot = await admin.database().ref('PassSystem/Students').once('value')
    const allStudentsPassData = snapshot.val()
    const currentStudentPassData = allStudentsPassData[id]
    if (currentStudentPassData === null) {
      return res.status(500).json("Student not found with ID number: " + id)
    }

    //move current info to log
    if (typeof currentStudentPassData["log"] === 'undefined') {
      currentStudentPassData["log"] = []
    }
    currentStudentPassData["log"].push({
      status: currentStudentPassData["currentStatus"],
      time: currentStudentPassData["timeOfStatusChange"]
    })


    //Get current time
    const timeOfStatusChange = dateString + " " + timeString

    
    //Get location data
    let location 
    if (req.query.location !== null && typeof req.query.location !== 'undefined') {
      location = " - " + req.query.location
    } else location = ""

    //Update current data
    if (req.query.forceSign.includes('in') || req.query.forceSign.includes('out')) {
      currentStudentPassData["currentStatus"] = "Signed " + req.query.forceSign.replace(/^\w/, c => c.toUpperCase())
    } else {
      currentStudentPassData["currentStatus"] = (currentStudentPassData["currentStatus"].toLowerCase().includes("out") ? "Signed In" : "Signed Out") + location
    }
    currentStudentPassData["timeOfStatusChange"] = timeOfStatusChange


    //Update firebase
    await admin.database().ref('PassSystem/Students/' + id).set(currentStudentPassData, error => {
      if (error) {
          return res.status(500).json(error)
      } else {
          return res.status(200).json({
            "Database updated sucessfully for id": id,
            "New Pass Data": currentStudentPassData
          })
      }
  })

})

exports.addStudentToPassDatabase = functions
  .region('us-east4')
  .runWith(opts).https.onRequest(async (req, res) => {
    const id = Number(req.query.studentIDNumber)
    const graduationYear = Number(req.query.graduationYear)
    const name = req.query.name
    if (isNaN(id) || id > 9999999999 || isNaN(graduationYear) || graduationYear < 2000 || graduationYear > 5000 || name === null) { 
      return res.status(400).json("Invalid student parameters")
    }


    let dateString = new Date().toLocaleDateString('en-US', { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric' }
    )
    let dateStringComponents = dateString.split('/')
    const timeString = new Date().toLocaleTimeString('en-US', {
      timeZone: "America/New_York"
    })
    let timeOfStatusChange = dateStringComponents[2] + "-" + dateStringComponents[0] + "-" + dateStringComponents[1] + " " + timeString

    const snapshot = await admin.database().ref('PassSystem/Students').once('value')
    let currentStudentsPassData = snapshot.val() === null ? {} : snapshot.val()
    if (currentStudentsPassData[id] !== null && typeof currentStudentsPassData[id] !== 'undefined') {
      return res.status(400).json("This ID has already been added. To update information for a student, you must do so manually through the database")
    }
    currentStudentsPassData[id] = {
      name: name,
      graduationYear: graduationYear,
      timeOfStatusChange: timeOfStatusChange,
      currentStatus: "Signed In"
    }

    await admin.database().ref('PassSystem/Students').set(currentStudentsPassData, error => {
      if (error) {
          return res.status(500).json("error: " + error)
      } else {
          return res.status(200).json(name + " with ID of " + id + " has successfully been added to the pass system.")
      }
  })

  })

exports.test = functions.region('us-east4').runWith(opts).https.onRequest( async (req, res) => {
  await signAllStudentsIn()
  return res.status(200).json("Succeeded")
})

async function signAllStudentsIn() {
  console.log("Signing outstanding students in at end of school day.")
  const snapshot = await admin.database().ref('PassSystem/Students').once('value')
  let currentStudentsPassData = snapshot.val()
  if (currentStudentsPassData === null) {
    return console.log("Pass System doesn't exist")
  }
  for (var student in currentStudentsPassData) {
    if (!currentStudentsPassData.hasOwnProperty(student) || currentStudentsPassData[student]["currentStatus"].includes("In")) continue;
    
    //move current info to log
    if (typeof currentStudentsPassData[student]["log"] === 'undefined') {
      currentStudentsPassData[student]["log"] = []
    }
    currentStudentsPassData[student]["log"].push({
      status: currentStudentsPassData[student]["currentStatus"],
      time: currentStudentsPassData[student]["timeOfStatusChange"]
    })


    //Get current time
    const dateStringComponents = new Date().toLocaleDateString('en-US', { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric' }
    ).split('/')
    const timeString = new Date().toLocaleTimeString('en-US', {
      timeZone: "America/New_York"
    })
    const dateString = dateStringComponents[2] + "-" + dateStringComponents[0] + "-" + dateStringComponents[1]

    const timeOfStatusChange = dateString + " " + timeString

    
    //Update current data
    currentStudentsPassData[student]["currentStatus"] = "Signed In"
    currentStudentsPassData[student]["timeOfStatusChange"] = timeOfStatusChange


    //Update firebase
    admin.database().ref('PassSystem/Students').set(currentStudentsPassData, error => {
      if (error) {
        return console.log("Error updating database")
      } else {
        return console.log("Outstanding signouts fixed")
      }
    })
  }
}