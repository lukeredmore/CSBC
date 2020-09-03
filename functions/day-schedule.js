const admin = require('firebase-admin')
if (process.env.FUNCTIONS_EMULATOR) { process.env.GOOGLE_APPLICATION_CREDENTIALS = "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json" }
const firebase = require('./firebase')

exports.update = async ({ after}) => {
    let {
      noElementarySchoolDays = [],
      noSchoolDays = [],
      noHighSchoolDays = [],
      snowDays = [],
      startDate: startDateString = '1970-01-01',
      endDate: endDateString = '1970-01-01',
    } = after.val()

    ensureDatesAreBetweenStartAndEnd(noElementarySchoolDays, startDateString, endDateString, 'noElementarySchoolDays')
    ensureDatesAreBetweenStartAndEnd(noSchoolDays, startDateString, endDateString, 'noSchoolDays')
    ensureDatesAreBetweenStartAndEnd(noHighSchoolDays, startDateString, endDateString, 'noHighSchoolDays')

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

const ensureDatesAreBetweenStartAndEnd = async (dateArr, startDateString, endDateString, varName) => {
  const startDate = new Date(startDateString + 'T14:00:00.000Z')
  const endDate = new Date(endDateString + 'T14:00:00.000Z')
  const datesBetweenStartAndEnd = dateArr.filter(dateString => {
    const date = new Date(dateString + 'T14:00:00.000Z')
    return date > startDate && date < endDate
  })
  if (datesBetweenStartAndEnd.length !== dateArr.length) {
    await firebase.writeToRef('Dates/' + varName, datesBetweenStartAndEnd)
  }
} 