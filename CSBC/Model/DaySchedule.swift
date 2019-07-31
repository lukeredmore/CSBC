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
    let startDateString : String = "09/04/2019" //first day of school
    let endDateString : String = "06/19/2020" //last day of school
    var dateDayDict : [String:[String:Int]] = [:]
    var dateDayDictArray : [String] = [""]
    
    let noSchoolDateStrings : [String] = ["10/11/2019", "10/14/2019", "11/05/2019", "11/11/2019", "11/27/2019", "11/28/2019", "11/29/2019", "12/23/2019", "12/24/2019", "12/25/2019", "12/26/2019", "12/27/2019", "12/30/2019", "12/31/2019", "01/01/2020", "01/20/2020", "02/14/2020", "02/17/2020", "03/12/2020", "03/13/2020", "04/06/2020", "04/07/2020", "04/08/2020", "04/09/2020", "04/10/2020", "04/13/2020", "05/21/2020", "05/22/2020", "05/25/2020"]
    let noElementarySchoolDateStrings : [String] = ["11/22/2019"]
    let noHighSchoolDateStrings : [String] = ["01/21/2020", "01/22/2020", "01/23/2020", "01/24/2020", "06/17/2020", "06/18/2020", "06/19/2020"]
    
    var snowDateStrings : [String] = []
    var dayScheduleOverides : [String : Int] = [:]
    
    var restrictedDates : [Date] = []
    var restrictedDatesForHS : [Date] = []
    var restrictedDatesForES : [Date] = []
    var restrictedDateStrings : [String] = []
    var restrictedDatesForHSStrings : [String] = []
    var restrictedDatesForESStrings : [String] = []
    
    var dateStringFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt
    }
    
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
        var date : Date = dateStringFormatter.date(from: startDateString)!
        let endDate : Date = dateStringFormatter.date(from: endDateString)!
        
        //print("appending no school")
        for dateString in noSchoolDateStrings {
            if let restrictedDate = dateStringFormatter.date(from: dateString) {
                restrictedDates.append(restrictedDate)
                restrictedDateStrings.append(dateString)
            }
        }
        //print("appending snow dates")
        for dateString in snowDateStrings {
            if let restrictedDate = dateStringFormatter.date(from: dateString) {
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
                if let restrictedDate = dateStringFormatter.date(from: dateString) {
                    restrictedDatesForHS.append(restrictedDate)
                    restrictedDatesForHSStrings.append(dateString)
                    print(restrictedDatesForHSStrings)
                    print(restrictedDatesForESStrings)
                }
            }
        }
        if forJohn || forSaints || forJames {
            //print("appending ptc dates")
            for dateString in noElementarySchoolDateStrings {
                if let restrictedDate = dateStringFormatter.date(from: dateString) {
                    restrictedDatesForES.append(restrictedDate)
                    restrictedDatesForESStrings.append(dateString)
                    print(restrictedDatesForHSStrings)
                    print(restrictedDatesForESStrings)
                }
            }
        }
        
        restrictedDatesForHS.sort()
        restrictedDatesForES.sort()
        
        print(restrictedDatesForHSStrings)
        print(restrictedDatesForESStrings)

        
        var setonDay = 1 + dayScheduleOverides["Seton"]!
        var johnDay = 1 + dayScheduleOverides["John"]!
        var saintsDay = 1 + dayScheduleOverides["Saints"]!
        var jamesDay = 1 + dayScheduleOverides["James"]!
        
        while date <= endDate {
            if Calendar.current.component(.weekday, from: date) != 1 && Calendar.current.component(.weekday, from: date) != 7 { //if its a weekday
                let dateString = dateStringFormatter.string(from: date)
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
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
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
        if !dateDayDictArray.contains(dateString) {
            dateDayDictArray.append(dateString)
        }
    }
}
