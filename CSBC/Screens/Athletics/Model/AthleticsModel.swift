//
//  AthleticsModel.swift
//  CSBC
//
//  Created by Luke Redmore on 3/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

struct AthleticsModel : Searchable {
    static func sortSectionsByThisParameter<T: Comparable>(_ lhs: T, _ rhs: T) -> Bool? {
        let lhsModel = lhs as! AthleticsModel
        let rhsModel = rhs as! AthleticsModel
        return lhsModel.date < rhsModel.date
    }
    
    var groupIntoSectionsByThisParameter: AnyHashable? { date }
    
    var sectionTitle: String? {
        guard let dateObj = Calendar.current.date(from: date) else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: dateObj)
    }
    
    var searchElements: String { "\(title) \(level) \(time) \(Calendar.current.date(from: date)?.dateString() ?? "")" }
    
    static var shouldStayGroupedWhenSearching: Bool? { true }
    
    static func < (lhs : AthleticsModel, rhs : AthleticsModel) -> Bool {
        return lhs.realDate < rhs.realDate
    }
    
    let title : String
    let level : String
    let time : String
    let date : DateComponents
    
    func toString() -> String {
        var toReturn = title.components(separatedBy: " ")[0] + " "
        toReturn += level
        toReturn += title.components(separatedBy: "'s")[1] + " on "
        toReturn += sectionTitle ?? "TBD"
        toReturn += " at " + self.time
        return toReturn
    }
    
    var realDate : Date {
        let fmt = DateFormatter()
        guard var dateString = Calendar.current.date(from: date)?.dateString() else { return Date() }
        dateString += " " + self.time
        fmt.dateFormat = "MM/dd/yyyy h:mm a"
        let dater = fmt.date(from: dateString)
        return dater ?? Date()
    }
}
