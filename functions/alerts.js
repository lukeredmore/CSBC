const puppeteer = require('puppeteer')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const admin = require('firebase-admin')
const daySchedule = require('./day-schedule.js')
const cheerio = require('cheerio')


//MARK: Snow day methods
exports.update = async (context) => {

  let response = await checkForAlerts()
  console.log(JSON.stringify(response))

  let daySched = await daySchedule.create()
  await admin.database().ref('DaySchedule').set(daySched, error=> {
    if (error) {
      console.log("Error updating database: " + JSON.stringifiy(error))
      return //res.status(500).send("Error updating database: " + JSON.stringifiy(error))
    } else {
      console.log("Database updated successfully with Day Schedule data")
      return //res.status(200).send("Database updated successfully with Calendar data")
    }
  })
}

async function checkForAlerts() {
  //Get alert message and add it to firebase
  let alertMessage = "nil"
  
  alertMessage = await checkForAlertFromCSBC()
  if (typeof alertMessage === 'undefined' || alertMessage === null || alertMessage === "nil") {
    alertMessage = await checkForAlertFromWBNG()
  }
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
      await admin.database().ref('SnowDays').set(snowDays, error=> {
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
      await page.goto('https://csbcsaints.org/our-schools/seton-catholic-central/about-scc/about/', { waitUntil: 'domcontentloaded' })
      let html = await page.content()
      let alertMessage = parseCSBCForCancellations(html)
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
      await page.goto('https://wbng.assets.quincymedia.com/newsticker/closings.html', { waitUntil: 'domcontentloaded' })
      let html = await page.content()
      let alertMessage = parseWBNGForCancellations(html)
      browser.close()
      return alertMessage
  } catch (e) {
    console.log("Checking for alert from WBNG failed with error: " + e)
    browser.close()
    return 'nil'
  }
}

function parseCSBCForCancellations(html) {
  const $ = cheerio.load(html)
  let text = null
  text = $('strong').first().text()
  text = text.replace('ALERT: ', '')
  text = text.replace('Alert: ', '')
  return text
}

function parseWBNGForCancellations(html) {
  let messageToReturn = 'nil'
  const $ = cheerio.load(html)
  $('tr').each((_, elem) => {
    const entry = $(elem).text().toLowerCase()
    if (entry.includes('catholic') && entry.includes('broome')) {
      console.log("WBNG Closed Data: " + entry)
      let cancellationData = entry.split(': ')[1]
      if (cancellationData === "closed" || cancellationData === "closed today") {
        messageToReturn = "The Catholic Schools of Broome County are closed today."
      }
      if (cancellationData.includes('delay')) {
        messageToReturn = "The Catholic Schools of Broome County are on a " + cancellationData + " schedule today."
      }
    }
  })
  return messageToReturn
}