if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const admin = require('firebase-admin')
const cheerio = require('cheerio')
const request = require('async-request')

exports.getLinks = async function() {
    let lunchOverride = (await admin.database().ref('Lunch/Override').once('value')).val()
    if (lunchOverride === true) { console.log("Lunch Menu Override active, not replacing lunch menus"); return }

    let currentLunchLinks = (await admin.database().ref('Lunch/Links').once('value')).val()
    if (!currentLunchLinks) { currentLunchLinks = {} }

    const lunchLinks = {
        "seton": await getSetonLunchLink(currentLunchLinks.seton),
        "johnjames": await getJohnAndJamesLunchLink(currentLunchLinks.johnjames),
        "saints": "https://csbcsaints.org/wp-content/uploads/Menu.doc"
    }
    await admin.database().ref('Lunch/Links').set(lunchLinks, error=> {
        if (error) {
          console.log("Error updating database: " + JSON.stringifiy(error))
        } else {
          console.log("Database updated successfully with lunch links")
        }
    })

}

async function getSetonLunchLink(defaultLink) {
  let link = defaultLink
  try {
    let response = await request('https://www.csbcsaints.org/our-schools/seton-catholic-central/about-scc/about/')
    const $ = cheerio.load(response.body)
    $(".mega-menu-link").each((i, e) => {
      const $ = cheerio.load(e)
      const text = $.text()
      if (text.toLowerCase().includes("menu")) {
        link = $('a').attr('href')
      }
    })
    return link
  }
  catch(error) { console.log(error); return defaultLink }
}

async function getJohnAndJamesLunchLink(defaultLink) {
  let link = defaultLink
  try {
    let response = await request('https://www.rockoncafe.org/Menus_B.aspx', {
      headers: {'user-agent': 'node.js'}
  })
    const $ = cheerio.load(response.body)
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
  catch(error) { console.log(error); return defaultLink }
}