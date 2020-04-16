const admin = require('firebase-admin')
if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}

exports.getDataFromRef = async refString => {
  try {
    let snapshot = await admin.database().ref(refString).once('value')
    return snapshot.val()
  } catch (err) {
    console.log(`Could not receive data from ${refString}: ${e}.`)
    return null
  }
}

exports.writeToRef = async (refString, data) => {
  try {
    await admin.database().ref(refString).set(data)
    console.log(`${data} succesfully written to ${refString}.`)
    return true
  } catch (err) {
    console.log(`Could not set ${data} at ${refString}: ${e}.`)
    return null
  }
}
