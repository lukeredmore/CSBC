if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS =
    "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json"
}
const schedule = require('./schedule.js')
const lunch = require('./lunch.js')
const admin = require('firebase-admin')


exports.test = async (req, res) => {
  let period = await lunch.getLinks()
  res.send(String(period))
}

exports.sendPeriodToDebug = async () => {
  let minutes = new Date().getMinutes()
  console.log(minutes + "  and   " + Math.floor((minutes / 10) % 10))
  if (minutes % 2 !== 0 || Math.floor((minutes / 10) % 10) % 2 !== 0) {
    return
  }

  let period = await schedule.getCurrentPeriod()
  let alertNotif = {
    notification: {
      title: "Current period testing",
      body: "The app says its now period " + period
    },
    android: {
      priority: "HIGH",
      ttl: 86400000,
      notification: { sound: "default" }
    },
    apns: {
      payload: {
        aps: {
          sound: "default"
        }
      }
    },
    condition: "('debugDevice' in topics)"
  }

  await admin
    .messaging()
    .send(alertNotif)
    .then(response => {
      console.log(
        "Successfully sent period message to debug: ",
        JSON.stringify(response)
      )
      return
    })
    .catch(error => {
      console.log("Error sending message: ", error)
      return
    })
}