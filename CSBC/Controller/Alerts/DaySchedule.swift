//
//  DaySchedule.swift
//  CSBC
//
//  Created by Luke Redmore on 2/27/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
//import Firebase

class DaySchedule {
    let startDateString : String = "09/05/2018" //first day of school
    let endDateString : String = "06/21/2019" //last day of school
    var dateDayDict : [String:[String:Int]] = [:]
    var dateDayDictArray : [String] = [""]
    
    let noSchoolDateStrings : [String] = ["10/05/2018", "10/08/2018", "11/12/2018", "11/21/2018", "11/22/2018", "11/23/2018", "12/24/2018", "12/25/2018", "12/26/2018", "12/27/2018", "12/28/2018", "12/31/2018", "01/01/2019", "02/15/2019", "02/18/2019", "03/14/2019", "03/15/2019", "03/18/2019", "04/15/2019", "04/16/2019", "04/17/2019", "04/18/2019", "04/19/2019", "04/22/2019", "05/23/2019", "05/24/2019", "05/27/2019"]
    let noElementarySchoolDateStrings : [String] = ["11/16/2018"]
    let noHighSchoolDateStrings : [String] = ["01/21/2019", "01/22/2019", "01/23/2019", "01/24/2019", "01/25/2019", "06/18/2019", "06/19/2019", "06/20/2019", "06/21/2019"]
    
    var snowDateStrings : [String] = [] //["02/22/2019", "02/25/2019", "02/26/2019", "02/27/2019"]
    var dayScheduleOverides : [String : Int] = [:]
    //var snowDateCount = 0
    
    //var schoolDates : [String:[String]]!
    
    var restrictedDates : [Date] = []
    var restrictedDatesForHS : [Date] = []
    var restrictedDatesForES : [Date] = []
    var restrictedDateStrings : [String] = []
    var restrictedDatesForHSStrings : [String] = []
    var restrictedDatesForESStrings : [String] = []
    
    init(forSeton : Bool = false, forJohn : Bool = false, forSaints : Bool = false, forJames : Bool = false) {
        if forSeton || forJohn || forSaints || forJames {
            restrictedDates.removeAll()
            snowDateStrings = UserDefaults.standard.array(forKey: "snowDays") as? [String] ?? []
            dayScheduleOverides = UserDefaults.standard.dictionary(forKey: "dayScheduleOverrides") as? [String:Int] ?? ["Seton":0,"John":0,"Saints":0,"James":0]
            if forSeton { dateDayDict["Seton"] = [:] }
            if forJohn { dateDayDict["St. John's"] = [:] }
            if forSaints { dateDayDict["All Saints"] = [:] }
            if forJames { dateDayDict["St. James"] = [:] }
            findDayOfCycle(forSeton : forSeton, forJohn : forJohn, forSaints : forSaints, forJames : forJames)
            
        }
        
    }
    
    func findDayOfCycle(forSeton : Bool, forJohn : Bool, forSaints : Bool, forJames : Bool) {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        var date : Date = fmt.date(from: startDateString)!
        let endDate : Date = fmt.date(from: endDateString)!
        
        //print("appending no school")
        for dateString in noSchoolDateStrings {
            if let restrictedDate = fmt.date(from: dateString) {
                restrictedDates.append(restrictedDate)
                restrictedDateStrings.append(dateString)
            }
        }
        //print("appending snow dates")
        for dateString in snowDateStrings {
            if let restrictedDate = fmt.date(from: dateString) {
                restrictedDates.append(restrictedDate)
                restrictedDateStrings.append(dateString)
            }
        }
        
        restrictedDatesForHSStrings = restrictedDateStrings
        restrictedDatesForESStrings = restrictedDateStrings
        restrictedDatesForHS = restrictedDates
        restrictedDatesForES = restrictedDates
        restrictedDates.removeAll()
        
        if forSeton {
            //print("appending exam dates")
            for dateString in noHighSchoolDateStrings {
                if let restrictedDate = fmt.date(from: dateString) {
                    restrictedDatesForHS.append(restrictedDate)
                    restrictedDatesForHSStrings.append(dateString)
                }
            }
        }
        if forJohn || forSaints || forJames {
            //print("appending ptc dates")
            for dateString in noElementarySchoolDateStrings {
                if let restrictedDate = fmt.date(from: dateString) {
                    restrictedDatesForES.append(restrictedDate)
                    restrictedDatesForESStrings.append(dateString)
                }
            }
        }
        
        restrictedDatesForHS.sort()
        restrictedDatesForES.sort()
        

        
        var setonDay = 1 + dayScheduleOverides["Seton"]!
        var johnDay = 1 + dayScheduleOverides["John"]!
        var saintsDay = 1 + dayScheduleOverides["Saints"]!
        var jamesDay = 1 + dayScheduleOverides["James"]!
        
        while date <= endDate {
            if Calendar.current.component(.weekday, from: date) != 1 && Calendar.current.component(.weekday, from: date) != 7 { //if its a weekday
                let dateString = fmt.string(from: date)
                if forSeton && !restrictedDatesForHSStrings.contains(dateString) {
                    dateDayDict["Seton"]![dateString] = setonDay
                    setonDay = proceedToNextDay(day: setonDay)
                    checkToAddDateToArray(dateString: dateString)
                }
                if forJohn && !restrictedDatesForESStrings.contains(dateString) {
                    dateDayDict["St. John's"]![dateString] = johnDay
                    johnDay = proceedToNextDay(day: johnDay)
                    checkToAddDateToArray(dateString: dateString)
                }
                if forSaints && !restrictedDatesForESStrings.contains(dateString) {
                    dateDayDict["All Saints"]![dateString] = saintsDay
                    saintsDay = proceedToNextDay(day: saintsDay)
                    checkToAddDateToArray(dateString: dateString)
                }
                if forJames && !restrictedDatesForESStrings.contains(dateString) {
                    dateDayDict["St. James"]![dateString] = jamesDay
                    jamesDay = proceedToNextDay(day: jamesDay)
                    checkToAddDateToArray(dateString: dateString)
                }
                
            }
            date += 86400//Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
        
        if dateDayDictArray[0] == "" {
            dateDayDictArray.remove(at: 0)
        }
        //print(dateDayDict)
        
    }
    

    func proceedToNextDay(day : Int) -> Int {
        var newDay = day + 1
        if newDay > 6 {
            newDay =  1
        }
        return newDay
    }
    
    func checkToAddDateToArray(dateString : String) {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        if !dateDayDictArray.contains(dateString) {
            dateDayDictArray.append(dateString)
        }
    }
}
