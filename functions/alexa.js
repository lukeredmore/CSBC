const daySchedule = require('./day-schedule.js')

//MARK: Methods for Alexa
/*
Parameters
date: date in yyyy-MM-dd format
school: 0 (elementary school) or 1 (high school)

Return
Day of cycle, if exists, or nothing if no school
*/
exports.getDayForDate = async (req, res) => {
    let date = req.query.date
    let school = Number(req.query.school)

    console.log("School requested is: " + school)
    console.log("Date requested is: " + date)
    let daySched = await daySchedule.create()
    if (school === 1) {
      return res.status(200).json(daySched.highSchool[date])
    } else if (school === 0) {
      return res.status(200).json(daySched.elementarySchool[date])
    } else {
      return res.status(200).json("Invalid request")
    }
}