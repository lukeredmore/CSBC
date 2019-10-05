//
//  DaySchedule.swift
//  CSBC
//
//  Created by Luke Redmore on 2/27/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import Firebase

class DaySchedule {
    
    private static var forElementarySchool : [String:Int] {
        return (UserDefaults.standard.object(forKey: "daySchedule") as? [String:[String:Int]])?["elementarySchool"] ?? [:]
    }
    private static var forHighSchool : [String:Int] {
        return (UserDefaults.standard.object(forKey: "daySchedule") as? [String:[String:Int]])?["highSchool"] ?? [:]
    }
    
    private static var dateStringFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }
    
    static func retrieveFromFirebase() {
        Database.database().reference().child("DaySchedule").observe(.value) { (snapshot) in
            guard let daySchedule = snapshot.value as? [String:[String:Int]] else { return }
            UserDefaults.standard.set(daySchedule, forKey: "daySchedule")
        }
    }
    
    ///Returns the day of cycle on any school date, or nil if date, school, or day schedule is invalid
    static func day(on dateOptional: Date?, for schoolOptional: Schools?) -> Int? {
        guard let school = schoolOptional, let date = dateOptional else { return nil }
        let dateString = dateStringFormatter.string(from: date)
        switch school {
        case .james, .john, .saints:
            return forElementarySchool[dateString]
        case .seton:
            return forHighSchool[dateString]
        }
    }
    
    static var endDate : Date {
        return dateStringFormatter.date(from: Array(forElementarySchool.keys).sorted().last!)!
    }
}
