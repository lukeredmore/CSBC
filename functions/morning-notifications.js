const daySchedule = require("./day-schedule.js")
if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS =
    "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json"
}
const admin = require("firebase-admin")
const notifications = require('./notifications.js')

//Sends day schedule notifications every morning
exports.createAndSend = async () => {
  /*Reset schedule to default*/
  await admin.database().ref("Schools/seton/scheduleInUse").set(1)

  await require("./lunch.js").getLinks()

  await createAndSendDayNotification()
  await createAndSendAlertNotification()

  return null
}

async function createAndSendDayNotification(sendingForReal = true) {
  /*Send Day Schedule Notification*/
  let todaysDateStringComponents = new Date()
    .toLocaleDateString("en-US", {
      timeZone: "America/New_York",
      day: "2-digit",
      month: "2-digit",
      year: "numeric"
    })
    .split("/")
  let todaysDateString =
    todaysDateStringComponents[2] +
    "-" +
    todaysDateStringComponents[0] +
    "-" +
    todaysDateStringComponents[1]
  let daySched = await daySchedule.create()
  console.log(JSON.stringify(daySched))
  console.log(todaysDateString)
  const hsDay = daySched.highSchool[todaysDateString]
  const esDay = daySched.elementarySchool[todaysDateString]
  console.log("hsDay: " + hsDay)
  console.log("esDay: " + esDay)
  let messagesToSend = createNotificationArray(hsDay, esDay)

  if (
    messagesToSend.length > 0 &&
    sendingForReal & (hsDayExists || esDayExists)
  ) {
    admin
      .messaging()
      .sendAll(messagesToSend)
      .then(response => {
        console.log(
          "Successfully sent day notification:",
          JSON.stringify(response)
        )
        return null
      })
      .catch(error => {
        console.log("Error sending message:", error)
        return null
      })
  } else {
    console.log(
      "Did not send day notification, as there was no school today, or have been overridden"
    )
  }

} 

async function createAndSendAlertNotification(sendingForReal = true) {
    /*Send Alert as Notification if present*/
    let alertMessage = (
      await admin
        .database()
        .ref("BannerAlertMessage")
        .once("value")
    ).val()
    if (
      sendingForReal &&
      typeof alertMessage !== "undefined" &&
      alertMessage !== null &&
      alertMessage !== "nil" &&
      alertMessage !== ""
    ) {
      let alertNotif = notifications.createNotificationObject(
        "Alert",
        alertMessage,
        "(('setonNotifications' in topics) || !('setonNotifications' in topics))"
      )
      admin
        .messaging()
        .sendAll(alertNotif)
        .then(response => {
          console.log("Successfully sent alert message:")
          console.log(response)
          return null
        })
        .catch(error => {
          console.log("Error sending message:")
          console.log(error)
          return null
        })
    } else {
      console.log(
        "Did not send alert notification, as there was no alert today"
      )
    }
    return
}


const createNotificationArray = (hsDay, esDay) => {
  const hsDayExists = hsDay !== null && typeof hsDay !== "undefined"
  const esDayExists = esDay !== null && typeof esDay !== "undefined"
  let arr = []

  if (hsDayExists) {
    arr.push(
      notifications.createNotificationObject(
        "Good Morning!",
        "Today is Day " + hsDay + " at Seton",
        "!('notReceivingNotifications' in topics) && ('setonNotifications' in topics && !('johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics))"
      )
    )
  }

  if (esDayExists) {
    arr.push(
      notifications.createNotificationObject(
        "Good Morning!",
        "Today is Day " + esDay + " at St. John's, St. James, and All Saints",
        "!('notReceivingNotifications' in topics) && (!('setonNotifications' in topics) && ('johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics))"
      )
    )
  }

  if (hsDayExists || esDayExists) {
    const hsString = hsDayExists
      ? "Today is Day " + hsDay + " at Seton, "
      : "There is no school at Seton today, "
    const esString = esDayExists
      ? "and today is Day " + esDay + " at the elementary schools."
      : "and there is no school at the elementary schools."
    arr.push(
      notifications.createNotificationObject(
        "Good Morning!",
        hsString + esString,
        "(!('notReceivingNotifications' in topics) && ('setonNotifications' in topics && ('johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics)))"
      )
    )
  }
  return arr
}
