const puppeteer = require('puppeteer')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const admin = require('firebase-admin')


exports.create = async function() {
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
    const restrictedDatesForHSStrings = noSchoolDateStrings + noHighSchoolDateStrings + snowDateStrings
    const restrictedDatesForESStrings = noSchoolDateStrings + noElementarySchoolDateStrings + snowDateStrings
    
    var date = new Date(startDateString)
    const endDate = new Date(endDateString)
        
    for (dateString of restrictedDatesForHSStrings) {
      restrictedDatesForHS.push(new Date(dateString))
    }
    for (dateString of restrictedDatesForESStrings) {
      restrictedDatesForES.push(new Date(dateString))
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



//MARK: Snow day methods
exports.update = async (context) => {

  let response = await checkForAlerts()
  console.log(JSON.stringify(response))

  let daySched = await parsers.daySchedule()
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