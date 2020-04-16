const puppeteer = require('puppeteer')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const admin = require('firebase-admin')
const cheerio = require('cheerio')
const passes = require('./passes.js')


//MARK: Snow day methods
exports.checkForAlerts = async () => {

  passes.checkForOutstandingStudents()

  let response = await checkForAlerts()
  console.log(JSON.stringify(response))
}

async function checkForAlerts() {
  //Get alert message and add it to firebase
  let alertMessage = await checkForAlertFromCSBC()
  let snowDayToday = await checkForAlertFromWBNG()
  let messageToReturn

  let snapshot = await admin.database().ref('BannerAlertOverride').once('value')
  let bannerAlertOverride = snapshot.val()
  if (bannerAlertOverride === false) {
    await admin.database().ref('BannerAlertMessage').set(alertMessage) }

  //Check if message calls for snow day today
  if (snowDayToday) {
    const dateString = new Date().toLocaleDateString('en-US', { 
      timeZone: "America/New_York",
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric' }
    )
    let snapshot = await admin.database().ref('SnowDays').once('value')
    let snowDays = Object.values(snapshot.val())

    //Runs if snow day hasn't been found before
    if (!snowDays.includes(dateString)) {
      snowDays.push(dateString)
      await admin.database().ref('SnowDays').set(snowDays, error=> {
        if (error) {
          console.log("Error updating database: " + JSON.stringifiy(error))
        } else {
          console.log("Database updated successfully with new snow day")
        }
        messageToReturn = {
          alertMessageText: alertMessage,
          firstTimeFindingSnowDay: true,
        }
      })
    } else {
      messageToReturn = {
        alertMessageText: alertMessage,
        firstTimeFindingSnowDay: false,
      }
    }
    
  } else {
    messageToReturn = {
      alertMessageText: alertMessage,
      snowDayTodayWasFound: snowDayToday
    }
  }
  return messageToReturn
}

async function checkForAlertFromCSBC() {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox']
  })
  try {
      const page = await browser.newPage()
      await page.goto('https://csbcsaints.org/our-schools/seton-catholic-central/about-scc/about/', { waitUntil: 'domcontentloaded' })
      let html = await page.content()
      let alertMessage = parseCSBCForCancellations(html)
      browser.close()
      return (typeof alertMessage !== 'undefined' && alertMessage !== null && alertMessage !== 'nil') ? alertMessage : "nil"
  } catch (e) {
    console.log("Checking for alert from CSBC website failed with error: " + e)
    browser.close()
    return "nil"
  }
}

async function checkForAlertFromWBNG() {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox']
  })
  try {
      const page = await browser.newPage()
      await page.goto('https://wbng.assets.quincymedia.com/newsticker/closings.html', { waitUntil: 'domcontentloaded' })
      let html = await page.content()
      let snowDayToday = parseWBNGForCancellations(html)
      browser.close()
      return snowDayToday
  } catch (e) {
    console.log("Checking for alert from WBNG failed with error: " + e)
    browser.close()
    return false
  }
}

function parseCSBCForCancellations(html) {
  const $ = cheerio.load(html)
  let text = null
  text = $('strong').first().text()
  text = text.replace('ALERT: ', '')
  text = text.replace('Alert: ', '')
  return text
}

function parseWBNGForCancellations(html) {
  let boolToReturn = false
  const $ = cheerio.load(html)
  $('tr').each((_, elem) => {
    const entry = $(elem).text().toLowerCase()
    if (entry.includes('catholic') && entry.includes('broome')) {
      console.log("WBNG Closed Data: " + entry)
      let cancellationData = entry.split(': ')[1]
      if (cancellationData === "closed" || cancellationData === "closed today") {
        boolToReturn = true
      }
    }
  })
  return boolToReturn
}