const firebase = require('./firebase')

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
    if (school === 1) {
      const day = await firebase.getDataFromRef('DaySchedule/highSchool/' + date)
      return res.status(200).json(day)
    } else if (school === 0) {
      const day = await firebase.getDataFromRef('DaySchedule/elementarySchool/' + date)
      return res.status(200).json(day)
    } else {
      return res.status(400).json("Invalid request")
    }
}