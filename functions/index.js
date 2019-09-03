const functions = require('firebase-functions')
const puppeteer = require('puppeteer')
const cheerio = require('cheerio')

const admin = require('firebase-admin')
admin.initializeApp()

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions

//Scrape calendar events for the next two months from CSBCSaints.org and parses it to a JSON array
const opts = {memory: '2GB', timeoutSeconds: 60}
exports.retrieveEventsArray = functions.runWith(opts).https.onRequest(async (req, res) => {
    let html1 = ""
    let html2 = ""

    res.locals.browser = await puppeteer.launch({
        args: ['--no-sandbox']
    })
    const browser = res.locals.browser
    try {
        const page = await browser.newPage()
        await page.goto('https://www.csbcsaints.org/calendar', { waitUntil: 'domcontentloaded' })
        html1 = await page.content()
        const nextButton = await page.$("#evcal_next")
        await nextButton.click()
        await page.waitFor(() => document.querySelector('#evcal_list').getAttribute('style') === "display: block;")
        html2 = await page.content()
    } catch (e) {
        res.status(500).send(e.toString())
    }

    const responseJSON = parseHTMLForEvents(html1).concat(parseHTMLForEvents(html2))
    res.status(200).json(responseJSON)

    const date = new Date()
    const currentTimeString = date.toISOString()
    const databaseJSON = {
        eventsArray: responseJSON,
        eventsArrayTime: currentTimeString,
        eventsArrayUpdating: "false"
    };

    await admin.database().ref('Calendars').set(databaseJSON, error => {
        if (error) {
            console.log("Error updating database: " + error)
        } else {
            console.log("Database updated successfully")
        }
    })
    console.log("Closing browser")
    await browser.close()
    return 
})

//Takes an html string and returns calendar events, if found. Only requires direct HTML of calendar object
function parseHTMLForEvents(html) {
    const dateAbbrv = {
      "jan": "01",
      "feb": "02",
      "mar": "03",
      "apr": "04",
      "may": "05",
      "jun": "06",
      "jul": "07",
      "aug": "08",
      "sep": "09",
      "oct": "10",
      "nov": "11",
      "dec": "12"
    }
    var data = []
    const $ = cheerio.load(html)
    $('#evcal_list .eventon_list_event').each((i, elem) => {
      const cell = $(elem).find('.desc_trig_outter').first()
  
      let titleString = cell.find('.evcal_event_title').first().text()
  
    //   console.log(titleString)
  
      let dateString = cell.find('.evo_start .date').first().text()
  
      let timeString = cell.find('.evcal_time').first().text().toUpperCase()
      if (timeString.includes("(ALL DAY")) {
        timeString = "All Day"
      }
  
      let schoolsString = cell.find('.ett1').first().text().replace("Schools:", "")
        
      if (titleString !== "" && dateString !== "") {
        data.push({
          title : titleString,
          date : cell.find('.evcal_cblock').attr('data-syr') + "-" + dateAbbrv[cell.find('.evo_start .month').first().text()] + "-" + dateString,
          time : timeString,
          schools : schoolsString
        })
      }
      
    })
    return data
  }
