if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const admin = require('firebase-admin')

/**
 * Ensure request is authenticated 
 * @param headers HTTP request headers used to find auth token
 * @param additionalPermissions Array of strings corresponding to additional permissions to check for (OR-based)
 * @returns null if authenticated, or a status message if not
 */
exports.authenticateRequest = async (headers, additionalPermissions = []) => {
    //Find auth token
    let authToken = null
    if (headers.authorization && headers.authorization.startsWith('Bearer ')) {
      authToken = headers.authorization.split('Bearer ')[1]
    } else return 'No user found - no auth token present'

    //Find user's email attached to auth token
    let userEmail = null
    try {
      const decodedToken = await admin.auth().verifyIdToken(authToken)
      if (!decodedToken || !decodedToken.email_verified) throw new Error('No verified user exists')
      userEmail = decodedToken.email
    } catch (err) {
      console.log(err)
      return 'Auth token verification failed'
    }

    //Ensure email has appropriate permissions
    try {
      const snapshot = await admin.database().ref('Users').once('value')
      const allUsers = Object.values(snapshot.val())
      const userInSystem = allUsers.find(e => e.email === userEmail)
      if (!userInSystem) {
        return 'User found, but is not registered as a user in the CSBC system'
      }

      let allPermissionsSatisfied = additionalPermissions === [] ? null : 'User found in CSBC system, but does not have the appropriate permissions'
      additionalPermissions.forEach(permission => {
          console.log(userInSystem)
          if (userInSystem[permission]) 
            allPermissionsSatisfied = null
      })
      return allPermissionsSatisfied
    } catch (err) {
      console.log(err)
      return "The user couldn't be authenticated: " + JSON.stringify(err)
    }
}
