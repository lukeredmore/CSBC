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

  let snapshot = await admin.database().ref('BannerAlertMessage').once('value')
  let alertMessage = snapshot.val()
  if (sendingForReal && typeof alertMessage !== 'undefined' && alertMessage !== null && alertMessage !== 'nil') {
    let alertNotif = { 
      //Both HS and ES
      notification: {
        title: "Alert",
        body: alertMessage
      },
      android: {
        priority: "HIGH",
        ttl: 86400000,
        notification: { sound: "default" }
      },
      apns: { payload: { aps: {
        sound: "default"
      } } },
      condition: "(('setonNotifications' in topics) || !('setonNotifications' in topics))",
    }
    admin.messaging().sendAll(alertNotif)
    .then((response) => {
      console.log('Successfully sent alert message:', JSON.stringify(response))
      return null
    })
    .catch((error) => {
      console.log('Error sending message:', error)
      return null
    })
  } else {
    console.log("Did not send alert notification, as there was no alert today")
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

exports.sendFromAdmin = async (req, res) => {
  const schoolNames = ["Seton Catholic Central", "St. John School", "All Saints School", "St. James School"]
  const schoolConditionals = ["setonNotifications","johnNotifications","saintsNotifications","jamesNotifications"]
  let alertNotif = { 
    notification: {
      title: schoolNames[req.query.schoolInt],
      body: req.query.message
    },
    android: {
      priority: "HIGH",
      ttl: 86400000,
      notification: { sound: "default" }
    },
    apns: { payload: { aps: {
      sound: "default"
    } } },
    condition: "('" + schoolConditionals[req.query.schoolInt] + "' in topics)"
  }
  
  await admin.messaging().send(alertNotif)
    .then(response => {
      console.log('Successfully sent alert message: ', JSON.stringify(response))
      return res.status(200).send('Successfully sent alert message: ' + JSON.stringify(response))
    })
    .catch(error => {
      console.log('Error sending message: ', error)
      return res.status(506).send('Error sending message: ' + error)
    }) 
}