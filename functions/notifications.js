if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS =
    "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json"
}
const constants = require('./constants.json')
const admin = require("firebase-admin")

const createNotificationObject = (title, body, condition) => {
  return {
    //Both HS and ES
    notification: {
      title: title,
      body: body
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
    condition: condition
  }
}

exports.createNotificationObject = createNotificationObject

exports.sendFromAdmin = async (req, res) => {
  let alertNotif = createNotificationObject(
    constants.SCHOOL_NAMES[req.query.schoolInt],
    req.query.message,
    constants.SCHOOL_CONDITIONALS[req.query.schoolInt]
  )
  console.log("Sending alert message with body of:")
  console.log(alertNotif)

  await admin
    .messaging()
    .send(alertNotif)
    .then(response => {
      console.log("Successfully sent alert message: ", JSON.stringify(response))
      return res
        .status(200)
        .send("Successfully sent alert message: " + JSON.stringify(response))
    })
    .catch(error => {
      console.log("Error sending message: ", error)
      return res.status(506).send("Error sending message: " + error)
    })
}
