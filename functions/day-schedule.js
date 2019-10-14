const admin = require('firebase-admin')
const constants = require('./constants.json')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }


exports.create = async function() {
    let snapshot = await admin.database().ref('SnowDays').once('value')
    const snowDateStrings = Object.values(snapshot.val())

    const startDateString = constants.FIRST_DAY_OF_SCHOOL
    const endDateString = constants.LAST_DAY_OF_SCHOOL
    var dateDayDict = {
      highSchool : {},
      elementarySchool : {}
    }

    var restrictedDatesForHS = []
    var restrictedDatesForES = []
    const restrictedDatesForHSStrings = constants.DATES_OF_NO_SCHOOL_IN_SYSTEM + constants.DATES_OF_NO_SCHOOL_IN_HIGH_SCHOOL + snowDateStrings
    const restrictedDatesForESStrings = constants.DATES_OF_NO_SCHOOL_IN_SYSTEM + constants.DATES_OF_NO_SCHOOL_IN_ELEMENTARY_SCHOOL + snowDateStrings
    
    var date = new Date(startDateString)
    const endDate = new Date(endDateString)
        
    for (dateString of restrictedDatesForHSStrings) {
      restrictedDatesForHS.push(new Date(dateString))
    }
    for (dateString of restrictedDatesForESStrings) {
      restrictedDatesForES.push(new Date(dateString))
    }
    var hsDay = 1
    var esDay = 1
    while (date <= endDate) {
      if (date.getDay() !== 0 && date.getDay() !== 6) { //if its a weekday
        let dateString = date.toLocaleDateString('en-US', { 
          day: '2-digit', 
          month: '2-digit', 
          year: 'numeric' }
        )
        let dateStringComponents = dateString.split('/')
        let dateToAddToDict = dateStringComponents[2] + "-" + dateStringComponents[0] + "-" + dateStringComponents[1]
        if (!restrictedDatesForHSStrings.includes(dateString)) {
          dateDayDict.highSchool[dateToAddToDict] = hsDay
          hsDay = hsDay <= 5 ? hsDay + 1 : 1
        }
        if (!restrictedDatesForESStrings.includes(dateString)) {
          dateDayDict.elementarySchool[dateToAddToDict] = esDay
          esDay = esDay <= 5 ? esDay + 1 : 1
        }
      }
      date.setDate(date.getDate() + 1);
    }
    return dateDayDict      
}