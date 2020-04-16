if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS = './csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json'
}
const admin = require('firebase-admin')
const cheerio = require('cheerio')
const fetch = require('node-fetch')

exports.getLinks = async function () {
  let schools = (await admin.database().ref('Schools').once('value')).val()
  
  if (schools.seton.info.autoURLUpdateEnabled) {
    let setonLink = await getSetonLunchLink()
    if (setonLink) {
      await admin.database().ref('Schools/seton/info/lunchURL').set(setonLink)
    }
  }

  if (schools.john.info.autoURLUpdateEnabled || schools.james.info.autoURLUpdateEnabled) {
    let johnJamesLink = await getJohnAndJamesLunchLink()
    if (johnJamesLink && schools.john.info.autoURLUpdateEnabled) {
      await admin.database().ref('Schools/john/info/lunchURL').set(johnJamesLink)
    }
    if (johnJamesLink && schools.james.info.autoURLUpdateEnabled) {
      await admin.database().ref('Schools/james/info/lunchURL').set(johnJamesLink)
    }
  }

  if (schools.saints.info.autoURLUpdateEnabled) {
    await admin.database().ref('Schools/saints/info/lunchURL').set('https://csbcsaints.org/wp-content/uploads/menu.pdf')
  }
}

async function getSetonLunchLink() {
  try {
    let response = await fetch('https://www.csbcsaints.org/our-schools/seton-catholic-central/about-scc/about/')
    let html = await response.text()

    const $ = cheerio.load(html)
    let link = null
    $('.mega-menu-link').each((i, e) => {
      const $ = cheerio.load(e)
      const text = $.text()
      if (text.toLowerCase().includes('menu')) {
        link = $('a').attr('href')
      }
    })
    console.log("SetonLunchLink: " + link)
    return link
  } catch (error) {
    console.log(error)
    return null
  }
}

async function getJohnAndJamesLunchLink() {
  try {
    let response = await fetch('https://www.rockoncafe.org/Menus_B.aspx', {
      headers: { 'user-agent': 'node.js' },
    })
    let html = await response.text()
    const $ = cheerio.load(html)
    let link = null
    $('.linksList').each((i, e) => {
      const $ = cheerio.load(e)
      $('li a').each((i, cell) => {
        const $ = cheerio.load(cell)
        const text = $.text()
        if (text.toLowerCase().includes('john')) {
          link = $('a').attr('href').replace(/ /g, '%20')
        }
      })
    })
    console.log('JohnJamesLunchLink: ' + link)
    return link
  } catch (error) {
    console.log(error)
    return null
  }
}
