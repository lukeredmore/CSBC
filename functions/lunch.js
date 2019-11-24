const puppeteer = require('puppeteer')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const admin = require('firebase-admin')
const cheerio = require('cheerio')

exports.getLinks = async function() {
    let snapshot = await admin.database().ref('LunchLinks/override').once('value')
    let lunchOverride = snapshot.val()
    if (lunchOverride === true) { return }

    const lunchLinks = {
        "seton": await getSetonLunch(),
        "johnjames": await getJohnAndJamesLunch(),
        "saints": await getSaintsLunch(),
        "override": false
    }
    await admin.database().ref('LunchLinks').set(lunchLinks, error=> {
        if (error) {
          console.log("Error updating database: " + JSON.stringifiy(error))
        } else {
          console.log("Database updated successfully with lunch links")
        }
    })

}

async function getSetonLunch() {
    const browser = await puppeteer.launch({
      args: ['--no-sandbox']
    })
    try {
        const page = await browser.newPage() 
        await page.goto('https://csbcsaints.org/our-schools/seton-catholic-central/about-scc/about/', { waitUntil: 'domcontentloaded' })
        let html = await page.content()
        let alertMessage = parseSetonForLink(html)
        browser.close()
        return alertMessage
    } catch (e) {
      console.log("Checking for alert from CSBC website failed with error: " + e)
      browser.close()
      return null
    }
  }

  function parseSetonForLink(html) {
    const $ = cheerio.load(html)
    let link = null
    $(".mega-menu-link").each((i, e) => {
        const $ = cheerio.load(e)
        const text = $.text()
        if (text.toLowerCase().includes("menu")) {
            link = $('a').attr('href')
        }
    })
    return link
  }

  async function getJohnAndJamesLunch() {
    const browser = await puppeteer.launch({
      args: ['--no-sandbox']
    })
    try {
        const page = await browser.newPage() 
        await page.goto('http://www.rockoncafe.org/Menus_B.aspx', { waitUntil: 'domcontentloaded' })
        let html = await page.content()
        let alertMessage = parseJohnAndJamesForLink(html)
        browser.close()
        return alertMessage
    } catch (e) {
      console.log("Checking for alert from CSBC website failed with error: " + e)
      browser.close()
      return null
    }
  }

  function parseJohnAndJamesForLink(html) {
    const $ = cheerio.load(html)
    let link = null
    $(".linksList").each((i, e) => {
        const $ = cheerio.load(e)
        $('li a').each((i, cell) => {
            const $ = cheerio.load(cell)
            const text = $.text()
            if (text.toLowerCase().includes("john")) {
                link = $('a').attr('href').replace(/ /g, '%20')
            }
        })
    })
    return link
  }

  async function getSaintsLunch() {
    const browser = await puppeteer.launch({
      args: ['--no-sandbox']
    })
    try {
        const page = await browser.newPage() 
        await page.goto('https://csbcsaints.org/our-schools/all-saints-school/parent-resources/lunch-menu-meal-program/', { waitUntil: 'domcontentloaded' })
        let html = await page.content()
        let alertMessage = parseSaintsForLink(html)
        browser.close()
        return alertMessage
    } catch (e) {
      console.log("Checking for alert from CSBC website failed with error: " + e)
      browser.close()
      return null
    }
  }

  function parseSaintsForLink(html) {
    const $ = cheerio.load(html)
    let link = null
    const month = new Date().toLocaleString('default', { month: 'long' })
    const year = new Date().getFullYear().toString().replace('20', '')
    $(".et_section_regular a").each((i, e) => {
        const $ = cheerio.load(e)
        const text = $.text()
        if (text.includes(year) && text.toLowerCase().includes(month.toLowerCase())) {// && !($('a').attr('href').includes("18"))) {
            link = $('a').attr('href')
        }
    })
    return link
  }