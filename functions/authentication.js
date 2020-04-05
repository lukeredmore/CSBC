if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const admin = require('firebase-admin')

exports.authenticateRequest = async (req, res) => {
    //Find auth token
    let authToken = null
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
      authToken = req.headers.authorization.split('Bearer ')[1]
    } else return res.status(403).json({ message: 'No user found - no auth token present' })

    //Find user's email attached to auth token
    let userEmail = null
    try {
      const decodedToken = await admin.auth().verifyIdToken(authToken)
      if (!decodedToken || !decodedToken.email_verified) throw new Error('No verified user exists')
      userEmail = decodedToken.email
    } catch (err) {
      console.log(err)
      return res.status(403).json({ message: 'Auth token verification failed' })
    }

    //Ensure email has appropriate permissions
    try {
      const snapshot = await admin.database().ref('Users').once('value')
      const allUsers = Object.values(snapshot.val())
      const emailInSystem = allUsers.find(e => e.email === userEmail)
      if (!emailInSystem) {
        return res.status(403).json({ message: 'User found, but is not allowed access' })
      }
    } catch (err) {
      console.log(err)
      return res.status(500).json({ message: 'Database Error, user could not be authenticated' })
    }
    return true
}
