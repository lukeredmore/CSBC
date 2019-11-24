const daySchedule = require('./day-schedule.js')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const admin = require('firebase-admin')

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
  let daySched = await daySchedule.create()
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
exports.createAndSend = async (context) => {
    const manuallyStopped = false
    if (manuallyStopped === false) {
      createAndSendDayNotification()
    }
    const lunch = require('./lunch.js')
    await lunch.getLinks()
}