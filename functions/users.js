if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const admin = require('firebase-admin')
const cors = require('cors')({ origin: true })
const authentication = require('./authentication.js')

exports.addOrModify = async (req, res) => {
  cors(req, res, async () => {
    const unauthenticated = await authentication.authenticateRequest(req.headers, ['dashboardAccess'])
    if (unauthenticated) return res.status(403).json({ message: unauthenticated })
    const { key, data } = req.body

    try {
      if (key && key !== 'null' && data && data !== 'null') {
            await admin.database().ref(`Users/${key}`).set(data)
            return res.status(200).json({ message: 'User successfully updated' })
      } else if (data && data !== 'null') {
            await admin.database().ref('Users').push(data)
            return res.status(200).json({ message: 'User successfully added to database' })
      } else if (key && key !== 'null') {
            await admin.database().ref(`Users/${key}`).remove()
            return res.status(200).json({ message: 'User successfully removed from database' })
      } else {
          return res.status(400).json({ message: "No data specified" })
      }
    } catch (e) {
        return res.status(500).json({ message: e })
    }
  })
}

exports.changeKey = async (req, res) => {
  cors(req, res, async () => {
    const unauthenticated = await authentication.authenticateRequest(req.headers, ['dashboardAccess', 'toggleAccess'])
    if (unauthenticated) return res.status(403).json({ message: unauthenticated })
    const { oldKey, newKey } = req.body

    try {
        const userSnapshot = await admin.database().ref(`Users/${oldKey}`).once('value')
        const user = userSnapshot.val()
        await admin.database().ref(`Users/${oldKey}`).remove()
        await admin.database().ref(`Users/${newKey}`).set(user)
        return res.status(200).json({ message: 'User key changed' })
    } catch (e) {
      return res.status(500).json({ message: e })
    }
  })
}