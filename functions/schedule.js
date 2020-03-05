if (process.env.FUNCTIONS_EMULATOR) {
  process.env.GOOGLE_APPLICATION_CREDENTIALS =
    "./csbcprod-firebase-adminsdk-hyxgt-2cfbbece24.json"
}
const constants = require("./constants.json")
const admin = require("firebase-admin")


//Methods to find current schedule
const getCurrentScheduleFromID = async () => {
  const scheduleInUse = (
    await admin
      .database()
      .ref("Schools/seton/scheduleInUse")
      .once("value")
  ).val()

  const allSchedules = (
    await admin
      .database()
      .ref("Schools/seton/schedules")
      .once("value")
  ).val()
  let filteredSchedule = allSchedules.filter(e => {
    return e.id === scheduleInUse
  })
  if (filteredSchedule && filteredSchedule[0] && filteredSchedule[0].times) {
    const sched = normalTimeFrom24HrTimeArray(filteredSchedule[0].times)
    console.log(
      "Array validation succeeded, returning following array of times: "
    )
    console.log(sched)
    console.log("For reference, here is the regular schedule:")
    console.log(constants.DEFAULT_TIMES_OF_PERIOD_START)
    return sched
  }
  console.log("Array validation failed, regular schedule returning:")
  return constants.DEFAULT_TIMES_OF_PERIOD_START
}

const getCurrentSchedule = async () => {
  const scheduleInUse = (
    await admin
      .database()
      .ref("Schools/seton/timesInUse")
      .once("value")
  ).val()
  return scheduleInUse
}

const normalTimeFrom24HrTimeArray = arr => {
  arr = arr.map(strTime => {
    let comp = strTime.split(":")
    let hour = Number(comp[0])
    let minute = Number(comp[1])
    if (minute === 0) {
      minute = 59
      hour = hour === 0 ? 23 : hour - 1
    } else {
      minute -= 1
    }
    if (hour === 0) {
      return "12:" + formatNumber(minute) + " AM"
    } else if (hour === 12) {
      return "12:" + formatNumber(minute) + " PM"
    } else if (hour < 13) {
      return hour + ":" + formatNumber(minute) + " AM"
    } else {
      hour -= 12
      return hour + ":" + formatNumber(minute) + " PM"
    }
  })
  return arr
}

const formatNumber = n => ("0" + n).slice(-2)

exports.createTimesInUse = async () => {
  let timesToAdd = await getCurrentScheduleFromID()
  await admin
    .database()
    .ref("Schools/seton/timesInUse")
    .set(timesToAdd)
}

const getCurrentPeriod = async () => {
  const dateString = new Date()
    .toLocaleDateString("en-US", {
      timeZone: "America/New_York",
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour12: false
    })
    .split("/")
  let timeString = new Date().toLocaleTimeString("en-US", {
    timeZone: "America/New_York",
    hour: "2-digit",
    minute: "2-digit",
    second: "numeric",
    hour12: false
  })
  let dateTimeString =
    dateString[2] + "-" + dateString[0] + "-" + dateString[1] + " " + timeString
  const currentDate = new Date(dateTimeString)
  console.log(currentDate)

  let todaysSchedule = await getCurrentSchedule()
  for (var i = 1; i < todaysSchedule.length; i++) {
    let lastBellDate = new Date(dateString + " " + todaysSchedule[i - 1])
    let nextBellDate = new Date(dateString + " " + todaysSchedule[i])

    if (currentDate >= lastBellDate && currentDate < nextBellDate) {
      console.log("we are in period " + i + "\n")
      return i
    }
  }
  return 0
}

exports.getCurrentPeriod = getCurrentPeriod