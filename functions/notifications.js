if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const constants = require('./constants.json')
const admin = require('firebase-admin')
const cors = require('cors')({origin: true})
const authentication = require('./authentication')

const createNotificationObject = (title, body, condition) => {
  return {
    //Both HS and ES
    notification: {
      title: title,
      body: body,
    },
    android: {
      priority: 'HIGH',
      ttl: 86400000,
      notification: { sound: 'default' },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
        },
      },
    },
    condition: condition,
  }
}

exports.createNotificationObject = createNotificationObject

exports.sendFromAdmin = async (req, res) => {
  cors(req, res, async () => {
    const unauthenticated = await authentication.authenticateRequest(req.headers, ['notificationSchool'])
    if (unauthenticated) return res.status(403).json({ message: unauthenticated })

    const { message, schoolInt } = req.body
    if (!req.body || !schoolInt || !constants.SCHOOL_NAMES[schoolInt] || !message)
      return res.status(400).json({ message: 'Invalid parameters' })

    let alertNotif = createNotificationObject(
      constants.SCHOOL_NAMES[schoolInt],
      message,
      constants.SCHOOL_CONDITIONALS[schoolInt]
    )
    console.log('Sending alert message with body of:')
    console.log(alertNotif)
    await admin
      .messaging()
      .send(alertNotif)
      .then(response => {
        console.log('Successfully sent alert message: ', JSON.stringify(response))
        return res.status(200).send('Successfully sent alert message: ' + JSON.stringify(response))
      })
      .catch(error => {
        console.log('Error sending message: ', error)
        return res.status(506).send('Error sending message: ' + error)
      })
  })
}

exports.sendNotification = async notificationObject => {
  await admin
    .messaging()
    .send(notificationObject)
    .then(response => {
      console.log('success')
      return 'Successfully sent alert message: ' + JSON.stringify(response)
    })
    .catch(error => {
      console.log(error)
      return 'Error sending message: ' + error
    })
}
