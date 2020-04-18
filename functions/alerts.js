if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const cheerio = require('cheerio')
const passes = require('./passes.js')
const firebase = require('./firebase.js')
const fetch = require('node-fetch')

//MARK: Snow day methods
exports.checkForAlerts = async () => {
  passes.checkForOutstandingStudents()

  let response = await checkForAlerts()
  console.log(JSON.stringify(response))
}

async function checkForAlerts() {
  let alertMessageText = await checkForAlertFromCSBC()
  let snowDayToday = await checkForAlertFromWBNG()

  //Update banner message if not overridden
  const bannerAlertOverride = await firebase.getDataFromRef('BannerAlert/override')
  if (!bannerAlertOverride) await firebase.writeToRef('BannerAlert/message', alertMessageText)

  //Return if no snow day today
  if (!snowDayToday) return { alertMessageText, snowDayToday }

  const snowDays = await firebase.getDataFromRef('Dates/snowDays')
  const dateString = firebase.getDatabaseReadableDateString(new Date())

  //Return if this snow day has been found before
  if (snowDays.includes(dateString)) {
    return {
      alertMessageText,
      firstTimeFindingSnowDay: false,
    }
  }

  await firebase.writeToRef('Dates/snowDays', [...snowDays, dateString])
  return {
    alertMessageText,
    firstTimeFindingSnowDay: true,
  }
}

//This checks for ANY alert on the site header. It will be added to the database and sent in a morning notification
async function checkForAlertFromCSBC() {
  try {
    let response = await fetch('https://csbcsaints.org/our-schools/seton-catholic-central/about-scc/about/')
    let html = await response.text()
    const $ = cheerio.load(html)
    let alertMessage = $(".divibars[data-bgcolor='#dd3333'] strong").first().text()
    return alertMessage && alertMessage !== '' ? alertMessage : null
  } catch (error) {
    console.log(error)
    return null
  }
}

//This ONLY checks for a snow day. It will NOT find a delay or anything similar
async function checkForAlertFromWBNG() {
  try {
    let response = await fetch(
      'https://web.archive.org/web/20170118142335/http://ftpcontent6.worldnow.com/wbng/newsticker/closings.html'
    )

    let html = await response.text()
    const $ = cheerio.load(html)
    let boolToReturn = false
    $('tr').each((_, elem) => {
      const entry = $(elem).text().toLowerCase()
      if (entry.includes('catholic') && entry.includes('broome')) {
        console.log('WBNG Closed Data: ' + entry)
        let cancellationData = entry.split(': ')[1]
        if (cancellationData === 'closed' || cancellationData === 'closed today') {
          boolToReturn = true
        }
      }
    })
    return boolToReturn
  } catch (error) {
    console.log(error)
    return null
  }
}
