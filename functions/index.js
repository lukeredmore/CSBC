const serviceAccount = require("./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json")
const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://csbcprod.firebaseio.com"
})
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const opts = { memory: "2GB", timeoutSeconds: 60 }


const alerts = require('./alerts.js')
exports.checkForAlerts = functions.region('us-east4').runWith(opts).pubsub.schedule('every 5 minutes').timeZone('America/New_York').onRun(alerts.checkForAlerts)


const daySchedule = require('./day-schedule.js')
exports.updateDayScheduleOnDatesUpdate = functions.region('us-east4').database.ref('/Dates').onUpdate(daySchedule.update)


const passes = require("./passes.js")
exports.deleteStudentFromPassDatabase = functions.region("us-east4").runWith(opts).https.onRequest(passes.deleteHandler)
exports.addStudentToPassDatabase = functions.region('us-east4').runWith(opts).https.onRequest(passes.addHandler)
exports.toggleStudentPassStatus = functions.region('us-east4').runWith(opts).https.onRequest(passes.toggleHandler)


const schedule = require("./schedule.js")
exports.createTimesInUse = functions.database.ref("/Schools/seton/scheduleInUse").onUpdate(schedule.createTimesInUse)


const alexa = require("./alexa.js")
exports.getDayForDate = functions.region('us-east4').https.onRequest(alexa.getDayForDate)


const events = require('./events.js')
exports.autoUpdateEvents = functions.runWith(opts).region('us-east4').pubsub.schedule('25 * * * *').timeZone('America/New_York').onRun(events.updateEvents)
exports.testEvents = functions.region('us-east4').runWith(opts).https.onRequest(events.updateEvents)


const morningNotifications = require('./morning-notifications.js')
exports.scheduledDayScheduleNotifications = functions.region("us-east4").pubsub.schedule("00 07 * * *").timeZone("America/New_York").onRun(morningNotifications.createAndSend)


const notifications = require('./notifications.js')
exports.sendMessageFromAdmin = functions.region('us-east4').runWith(opts).https.onRequest(notifications.sendFromAdmin)


const email = require('./email.js')
exports.sendReportEmail = functions.region('us-east4').runWith(opts).https.onRequest(email.createAndSend)


const users = require('./users.js')
exports.addOrModifyUsers = functions.region('us-east4').runWith(opts).https.onRequest(users.addOrModify)
exports.changeUserKey = functions.region('us-east4').runWith(opts).https.onRequest(users.changeKey)
