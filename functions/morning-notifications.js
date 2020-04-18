if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const admin = require('firebase-admin')
const notifications = require('./notifications.js')
const firebase = require('./firebase')

//Sends day schedule notifications every morning
exports.createAndSend = async () => {
  /*Reset schedule to default*/
  await firebase.writeToRef('Schools/seton/scheduleInUse', 1)

  await createAndSendDayNotification()
  await createAndSendAlertNotification()

  await require('./lunch.js').getLinks()
}

/*Send Day Schedule Notification*/
async function createAndSendDayNotification() {
  let todaysDateStringComponents = new Date()
    .toLocaleDateString('en-US', {
      timeZone: 'America/New_York',
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    })
    .split('/')
  let todaysDateString =
    todaysDateStringComponents[2] + '-' + todaysDateStringComponents[0] + '-' + todaysDateStringComponents[1]

  console.log("Today's date: " + todaysDateString)
  const hsDay = await firebase.getDataFromRef('DaySchedule/highSchool/' + todaysDateString)
  const esDay = await firebase.getDataFromRef('DaySchedule/elementarySchool/' + todaysDateString)
  console.log('hsDay: ' + hsDay)
  console.log('esDay: ' + esDay)

  let messagesToSend = createNotificationArray(hsDay, esDay)

  if (messagesToSend.length === 0 || (!hsDay && !esDay)) {
    console.log('Not sending day notification because there is no school today.')
    return
  }

  try {
    let response = await admin.messaging().sendAll(messagesToSend)
    console.log('Successfully sent day notification:', JSON.stringify(response))
  } catch (err) {
    console.log('Error sending message:', err)
  }
}

/*Send Alert as Notification if present*/
async function createAndSendAlertNotification() {
  let bannerAlert = await firebase.getDataFromRef('BannerAlert')
  const { message, previousMessages } = bannerAlert

  console.log("Banner message: " + message)

  if (!message || message === '' || message === 'nil' || message === 'null') {
    console.log('Not sending alert notification because no banner message was found.')
    return
  }
  if (previousMessages && Object.values(previousMessages).includes(message)) {
    console.log('Not sending alert notification because this message has already been sent')
    return
  }

  let alertNotif = notifications.createNotificationObject(
    'Alert',
    message,
    "(('setonNotifications' in topics) || !('setonNotifications' in topics))"
  )
  try {
    let response = await admin.messaging().send(alertNotif)
    console.log('Successfully sent alert message:')
    console.log(response)
    await admin.database().ref('BannerAlert/previousMessages').push(message)
  } catch (err) {
    console.log('Error sending message:')
    console.log(err)
  }
}

const createNotificationArray = (hsDay, esDay) => {
  const hsDayExists = hsDay !== null && typeof hsDay !== 'undefined'
  const esDayExists = esDay !== null && typeof esDay !== 'undefined'
  let arr = []

  if (hsDayExists) {
    arr.push(
      notifications.createNotificationObject(
        'Good Morning!',
        'Today is Day ' + hsDay + ' at Seton',
        "!('notReceivingNotifications' in topics) && ('setonNotifications' in topics && !('johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics))"
      )
    )
  }

  if (esDayExists) {
    arr.push(
      notifications.createNotificationObject(
        'Good Morning!',
        'Today is Day ' + esDay + " at St. John's, St. James, and All Saints",
        "!('notReceivingNotifications' in topics) && (!('setonNotifications' in topics) && ('johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics))"
      )
    )
  }

  if (hsDayExists || esDayExists) {
    const hsString = hsDayExists ? 'Today is Day ' + hsDay + ' at Seton, ' : 'There is no school at Seton today, '
    const esString = esDayExists
      ? 'and today is Day ' + esDay + ' at the elementary schools.'
      : 'and there is no school at the elementary schools.'
    arr.push(
      notifications.createNotificationObject(
        'Good Morning!',
        hsString + esString,
        "(!('notReceivingNotifications' in topics) && ('setonNotifications' in topics && ('johnNotifications' in topics || 'saintsNotifications' in topics || 'jamesNotifications' in topics)))"
      )
    )
  }
  return arr
}
