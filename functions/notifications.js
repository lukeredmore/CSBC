if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS =
    "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json"
}
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
  const schoolNames = [
    "Seton Catholic Central",
    "St. John School",
    "All Saints School",
    "St. James School"
  ]
  const schoolConditionals = [
    "setonNotifications",
    "johnNotifications",
    "saintsNotifications",
    "jamesNotifications"
  ]
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
    apns: {
      payload: {
        aps: {
          sound: "default"
        }
      }
    },
    condition: "('" + schoolConditionals[req.query.schoolInt] + "' in topics)"
  }

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
