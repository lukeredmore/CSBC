const functions = require('firebase-functions')
const puppeteer = require('puppeteer')
const cheerio = require('cheerio')
const XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest
const PrivateAPIKeys = require("./keys.js")

const admin = require('firebase-admin')
admin.initializeApp()

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions

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

//Takes an html string and returns calendar events, if found. Only requires direct HTML of calendar object
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

  var restrictedDatesForHS = []
  var restrictedDatesForES = []
  var restrictedDatesForHSStrings = []
  var restrictedDatesForESStrings = []
  
  var date = new Date(startDateString)
  const endDate = new Date(endDateString)
      
  //print("pushing no school")
  for (dateString of noSchoolDateStrings) {
    restrictedDatesForHS.push(new Date(dateString))
    restrictedDatesForHSStrings.push(dateString)
    restrictedDatesForES.push(new Date(dateString))
    restrictedDatesForESStrings.push(dateString)
  }
  //print("pushing snow dates")
  for (dateString of snowDateStrings) {
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
      let dateString = date.toLocaleDateString('en-US', { day: '2-digit', month: '2-digit', year: 'numeric' })
      if (!restrictedDatesForHSStrings.includes(dateString)) {
        dateDayDict.highSchool[dateString] = hsDay
        hsDay = hsDay <= 5 ? hsDay + 1 : 1
      }
      if (!restrictedDatesForESStrings.includes(dateString)) {
        dateDayDict.elementarySchool[dateString] = esDay
        esDay = esDay <= 5 ? esDay + 1 : 1
      }
    }
    date.setDate(date.getDate() + 1);
  }
  return dateDayDict      
}
async function createAndSendDayNotification(key) {
  let todaysDateString = new Date().toLocaleDateString('en-US', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  })
  let daySched = await daySchedule()
  console.log(new Date())
  console.log(daySched)
  console.log(todaysDateString)
  let hsDay = daySched.highSchool[todaysDateString]
  let esDay = daySched.elementarySchool[todaysDateString]

  let hsString = hsDay !== null ? "Today is Day " + hsDay + " at Seton." : "There is no school at Seton today."
  let esString = esDay !== null ? "Today is Day " + esDay + " at the elementary schools." : "There is no school at the elementary schools today."

  if (hsDay !== null && esDay !== null && hsDay === esDay) {
    hsString = "Today is Day " + hsDay + " at all schools."
    esString = ""
  }

  if (!hsString.includes("There is no school") || !esString.includes("There is no school")) {
    sendPushNotificationToAllUsers(key, "Good morning!", hsString + " " + esString, response => {
      console.log("Sucessfully sent day notification!!")
      // res.status(200).send("Sucessfully sent day notification")
    })
  } else {
    console.log("Did not send day notification, as there was no school today")
    // res.status(200).send("Did not send day notification, as there was no school today")
  }
  return
}
function sendPushNotificationToAllUsers(key, title, message, response) {
  let parameters = 
  { "notification": {
      "title": title,
      "body": message,
      "sound": "default"
  },
    "condition": "'appUser' in topics || 'setonNotifications' in topics",
    "priority": "high"
  }
  var xhr = new XMLHttpRequest();
  xhr.open('POST', "https://fcm.googleapis.com/fcm/send");
  xhr.onreadystatechange = function() {
      if (xhr.readyState>3 && xhr.status===200) { response(xhr.responseText); }
  };
  xhr.setRequestHeader("Content-Type", "application/json");
xhr.setRequestHeader("Authorization", key);
  xhr.send(JSON.stringify(parameters));
  return xhr;
}

//Sends day schedule notifications every morning
exports.scheduledDayScheduleNotifications = functions.pubsub.schedule('00 07 * * *')
  .timeZone('America/New_York')
  .onRun((context) => {
    const manuallyStopped = false
    if (manuallyStopped === false) {
      createAndSendDayNotification(PrivateAPIKeys.PRODUCTION_NOTIFICATION_KEY)
      createAndSendDayNotification(PrivateAPIKeys.DEBUG_NOTIFICATION_KEY)
    }
    return null;
});

exports.tester = functions
  .region('us-east4')
  .runWith(opts).https.onRequest(async (req, res) => {
  await createAndSendDayNotification(PrivateAPIKeys.DEBUG_NOTIFICATION_KEY)
})