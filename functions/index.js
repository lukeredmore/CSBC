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

exports.getDayForDate = functions
  .region('us-east4')
  .https.onRequest(async (req, res) => {
    let date = req.query.date
    let school = req.query.school

    console.log(school)
    console.log(date)
    let daySched = await daySchedule()
    if (school === 1) {
      return res.status(200).send(daySched.highSchool[date])
    } else if (school === 0) {
      return res.status(200).send(daySched.elementarySchool[date])
    } else {
      return res.status(200).send("Invalid request")
    }
  })

//Scrape calendar events for the next two months from CSBCSaints.org and parses it to a JSON array
const opts = {memory: '2GB', timeoutSeconds: 60}
exports.retrieveEventsArray = functions
  .region('us-east4')
  .runWith(opts).https.onRequest(async (req, res) => {
    let html1 = ""
    let html2 = ""

    res.locals.browser = await puppeteer.launch({
        args: ['--no-sandbox']
    })
    const browser = res.locals.browser
    try {
        const page = await browser.newPage()
        await page.goto('https://www.csbcsaints.org/calendar', { waitUntil: 'domcontentloaded' })
        html1 = await page.content()
        const nextButton = await page.$("#evcal_next")
        await nextButton.click()
        await page.waitFor(() => document.querySelector('#evcal_list').getAttribute('style') === "display: block;")
        html2 = await page.content()
    } catch (e) {
        res.status(500).send(e.toString())
    }

    const responseJSON = parseHTMLForEvents(html1).concat(parseHTMLForEvents(html2))
    res.status(200).json(responseJSON)

    const date = new Date()
    const currentTimeString = date.toISOString()
    const databaseJSON = {
        eventsArray: responseJSON,
        eventsArrayTime: currentTimeString,
        eventsArrayUpdating: "false"
    };

    await admin.database().ref('Calendars').set(databaseJSON, error => {
        if (error) {
            console.log("Error updating database: " + error)
        } else {
            console.log("Database updated successfully")
        }
    })
    console.log("Closing browser")
    await browser.close()
    return 
})
exports.autoUpdateEvents = functions.runWith(opts)
  .region('us-east4')
  .pubsub.schedule('25 * * * *')
  .timeZone('America/New_York')
  .onRun(async (context) => {

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
  
    //   console.log(titleString)
  
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
  console.log(snowDateStrings)

  var restrictedDatesForHS = []
  var restrictedDatesForES = []
  var restrictedDatesForHSStrings = []
  var restrictedDatesForESStrings = []
  
  var date = new Date(startDateString)
  console.log(date)
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



exports.test2 = functions
  .region('us-east4')
  .runWith(opts).https
  .onRequest(async (req, res) => {
    
  })

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