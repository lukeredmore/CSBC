const puppeteer = require('puppeteer')
const admin = require('firebase-admin')
if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const cheerio = require('cheerio')

//Scrape calendar events for the next two months from CSBCSaints.org and parses it to a JSON array
exports.updateEvents = async () => {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox'],
  })
  try {
    const page = await browser.newPage()
    await page.goto('https://www.csbcsaints.org/calendar', { waitUntil: 'domcontentloaded' })
    var html1 = await page.content()
    const nextButton = await page.$('#evcal_next')
    if (nextButton) {
      await nextButton.click()
      await page.waitFor(() => document.querySelector('#evcal_list').getAttribute('style') === 'display: block;')
      var html2 = await page.content()
    }
  } catch (e) {
    console.log(e)
  }

  const responseJSON = [...parseHTMLForEvents(html1 || ''), ...parseHTMLForEvents(html2 || '')]

  const dateString = new Date().toLocaleDateString('en-US', {
    timeZone: 'America/New_York',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  })
  const timeString = new Date().toLocaleTimeString('en-US', {
    timeZone: 'America/New_York',
  })
  const databaseJSON = {
    eventsArray: responseJSON,
    eventsArrayTime: dateString + ' ' + timeString,
  }

  await admin
    .database()
    .ref('Calendars')
    .set(databaseJSON, error => {
      if (error) console.log('Error updating database: ' + JSON.stringifiy(error))
      else console.log('Database updated successfully with Calendar data')
    })
  await browser.close()
  return
}

function parseHTMLForEvents(html) {
  const dateAbbrv = {
    jan: '01',
    feb: '02',
    mar: '03',
    apr: '04',
    may: '05',
    jun: '06',
    jul: '07',
    aug: '08',
    sep: '09',
    oct: '10',
    nov: '11',
    dec: '12',
  }
  var data = []
  const $ = cheerio.load(html)
  $('#evcal_list .eventon_list_event').each((_, elem) => {
    const cell = $(elem).find('.desc_trig_outter').first()

    let titleString = cell.find('.evcal_event_title').first().text()

    let dateString = cell.find('.evo_start .date').first().text()

    let timeString = cell.find('.evcal_time').first().text().toUpperCase()
    if (timeString.includes('(ALL DAY')) {
      timeString = 'All Day'
    }

    let schoolsString = cell.find('.ett1').first().text().replace('Schools:', '')

    if (titleString !== '' && dateString !== '') {
      data.push({
        title: titleString,
        date:
          cell.find('.evcal_cblock').attr('data-syr') +
          '-' +
          dateAbbrv[cell.find('.evo_start .month').first().text()] +
          '-' +
          dateString,
        time: timeString,
        schools: schoolsString,
      })
    }
  })
  return data
}
