if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS =
    "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json"
}
const daySchedule = require('./day-schedule.js')
const lunch = require('./lunch.js')
const admin = require('firebase-admin')
const passes = require('./passes')
const notifications = require('./notifications')
const morning = require('./morning-notifications')

exports.test = async (req, res) => {
  let resp = await daySchedule.create()
  res.send(resp)
}



const sendPeriodToDebug = async () => {
  /* Run only on even times
  let minutes = new Date().getMinutes()
  console.log(minutes + "  and   " + Math.floor((minutes / 10) % 10))
  if (minutes % 2 !== 0 || Math.floor((minutes / 10) % 10) % 2 !== 0) {
    return
  }*/

  let period = await schedule.getCurrentPeriod()
  let alertNotif = notifications.createNotificationObject(
    "test",
    "The app says its now period " + period,
    "('notifyOutstanding' in topics)"
  )

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

exports.sendPeriodToDebug = sendPeriodToDebug 