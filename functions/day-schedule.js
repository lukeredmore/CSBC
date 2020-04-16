const admin = require('firebase-admin')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const firebase = require('./firebase')

exports.update = async () => {
    let noSchoolDays = await firebase.getDataFromRef('Dates/noSchoolDays')
    let noHighSchoolDays = await firebase.getDataFromRef('Dates/noHighSchoolDays')
    let noElementarySchoolDays = await firebase.getDataFromRef('Dates/noElementarySchoolDays')
    let snowDays = await firebase.getDataFromRef('Dates/snowDays')

    const startDateString = await firebase.getDataFromRef('Dates/startDate')
    const endDateString = await firebase.getDataFromRef('Dates/endDate')

    var dateDayDict = {
      highSchool : {},
      elementarySchool : {}
    }

    const restrictedDatesForHS = [...noSchoolDays, ...noHighSchoolDays, ...snowDays]
    const restrictedDatesForES = [...noSchoolDays, ...noElementarySchoolDays, ...snowDays]

    var date = new Date(startDateString + "T14:00:00.000Z")
    const endDate = new Date(endDateString + 'T14:00:00.000Z')

    var hsDay = 1
    var esDay = 1
    while (date <= endDate) {
      if (date.getDay() !== 0 && date.getDay() !== 6) { //if its a weekday

        let dateString = date.toISOString().split("T")[0]
        if (!restrictedDatesForHS.includes(dateString)) {
          dateDayDict.highSchool[dateString] = hsDay
          hsDay = hsDay <= 5 ? hsDay + 1 : 1
        }
        if (!restrictedDatesForES.includes(dateString)) {
          dateDayDict.elementarySchool[dateString] = esDay
          esDay = esDay <= 5 ? esDay + 1 : 1
        }
      }
      date.setDate(date.getDate() + 1);
    }

    await firebase.writeToRef("DaySchedule", dateDayDict)

    return dateDayDict      
}