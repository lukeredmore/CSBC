const puppeteer = require('puppeteer')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const admin = require('firebase-admin')
const daySchedule = require('./day-schedule.js')


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