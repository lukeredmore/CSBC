//
//  DaySchedule.swift
//  CSBC
//
//  Created by Luke Redmore on 2/27/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

class DaySchedule {
    let startDateString : String = "09/04/2019" //first day of school
    let endDateString : String = "06/19/2020" //last day of school
    private var dateDayDict = [Schools:[String:Int]]()
//    private(set) var dateDayDictSet = Set<String>()
    
    private let noSchoolDateStrings = ["10/11/2019", "10/14/2019", "11/05/2019", "11/11/2019", "11/27/2019", "11/28/2019", "11/29/2019", "12/23/2019", "12/24/2019", "12/25/2019", "12/26/2019", "12/27/2019", "12/30/2019", "12/31/2019", "01/01/2020", "01/20/2020", "02/14/2020", "02/17/2020", "03/12/2020", "03/13/2020", "04/06/2020", "04/07/2020", "04/08/2020", "04/09/2020", "04/10/2020", "04/13/2020", "05/21/2020", "05/22/2020", "05/25/2020"]
    private let noElementarySchoolDateStrings = ["11/22/2019"]
    private let noHighSchoolDateStrings = ["09/13/2019", "01/21/2020", "01/22/2020", "01/23/2020", "01/24/2020", "06/17/2020", "06/18/2020", "06/19/2020"]
    
    private var snowDateStrings : [String]!
    
    
    private(set) var restrictedDatesForHS = [Date]()
    private(set) var restrictedDatesForES = [Date]()
    private var restrictedDatesForHSStrings = [String]()
    private var restrictedDatesForESStrings = [String]()
    
    private var dateStringFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt
    }
    
    init(forSeton : Bool = false, forElementary : Bool = false) {
        if forSeton || forElementary {
            snowDateStrings = UserDefaults.standard.array(forKey: "snowDays") as? [String] ?? ["12/25/2019"]
            if forSeton { dateDayDict[.seton] = [:] }
            if forElementary { dateDayDict[.john] = [:]; dateDayDict[.saints] = [:]; dateDayDict[.james] = [:] }
            findDayOfCycle(forSeton : forSeton, forElementary: forElementary)
            
        }
        
    }
    
    private func findDayOfCycle(forSeton : Bool, forElementary : Bool) {
        var restrictedDates = [Date]()
        var restrictedDateStrings = [String]()
        
        //print("appending no school and snow days")
        for dateString in noSchoolDateStrings + snowDateStrings where dateStringFormatter.date(from: dateString) != nil {
            restrictedDates.append(dateStringFormatter.date(from: dateString)!)
            restrictedDateStrings.append(dateString)
        }
        
        restrictedDatesForHSStrings = restrictedDateStrings
        restrictedDatesForESStrings = restrictedDateStrings
        restrictedDatesForHS = restrictedDates
        restrictedDatesForES = restrictedDates

        //print("appending exam dates")
        for dateString in noHighSchoolDateStrings where forSeton && dateStringFormatter.date(from: dateString) != nil {
            restrictedDatesForHS.append(dateStringFormatter.date(from: dateString)!)
            restrictedDatesForHSStrings.append(dateString)
        }
        //print("appending ptc dates")
        for dateString in noElementarySchoolDateStrings where (forElementary) && dateStringFormatter.date(from: dateString) != nil {
            restrictedDatesForES.append(dateStringFormatter.date(from: dateString)!)
            restrictedDatesForESStrings.append(dateString)
        }
        
        restrictedDatesForHS.sort()
        restrictedDatesForES.sort()
        
        var setonDay = 1, elementaryDay = 1
        let startDate : Date = dateStringFormatter.date(from: startDateString)!
        let endDate : Date = dateStringFormatter.date(from: endDateString)!

        
        for currentDate in stride(from: startDate, to: endDate, by: 86400) where (2..<7).contains(Calendar.current.component(.weekday, from: currentDate)) {
            let dateString = dateStringFormatter.string(from: currentDate)
            if forSeton && !restrictedDatesForHSStrings.contains(dateString) {
                dateDayDict[.seton]![dateString] = setonDay
                setonDay = proceedToNextDay(day: setonDay)
            }
            if forElementary && !restrictedDatesForESStrings.contains(dateString) {
                dateDayDict[.john]![dateString] = elementaryDay
                dateDayDict[.saints]![dateString] = elementaryDay
                dateDayDict[.james]![dateString] = elementaryDay
                elementaryDay = proceedToNextDay(day: elementaryDay)
            }
        }
    }
    

    private func proceedToNextDay(day : Int) -> Int {
        var newDay = day + 1
        if newDay > 6 {
            newDay =  1
        }
        return newDay
    }
    
    func getDay(forSchool schoolOptional: Schools?, forDate dateOptional: Date?) -> Int {
        if let school = schoolOptional, let date = dateOptional {
            let dateString = dateStringFormatter.string(from: date)
            guard let schoolSchedule = dateDayDict[school] else { return 0 }
            return schoolSchedule[dateString] ?? 0
        } else { return 0 }
    }
    func getDay(forSchool schoolOptional: Schools?, forDateString dateStringOptional: String?) -> Int {
        if let school = schoolOptional, let dateString = dateStringOptional {
            guard let schoolSchedule = dateDayDict[school] else { return 0 }
            return schoolSchedule[dateString] ?? 0
        } else { return 0 }
    }
    func getDayOptional(forSchool schoolOptional: Schools?, forDateString dateStringOptional: String?) -> Int? {
        if let school = schoolOptional, let dateString = dateStringOptional {
            guard let schoolSchedule = dateDayDict[school] else { return nil }
            return schoolSchedule[dateString] ?? nil
        } else { return nil }
    }
}
