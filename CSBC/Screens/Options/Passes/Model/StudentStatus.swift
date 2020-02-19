//
//  StudentStatus.swift
//  CSBC
//
//  Created by Luke Redmore on 11/7/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

struct StudentStatus : Searchable {
    static func < (lhs: StudentStatus, rhs: StudentStatus) -> Bool { lhs.time < rhs.time }
    
    var groupIntoSectionsByThisParameter: AnyHashable? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: time)
    }
    
    var sectionTitle: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: time)
    }
    
    var searchElements: String {
        let dateSearchFormatter = DateFormatter()
        dateSearchFormatter.dateFormat = " MM/dd/yy h:mm a"
        return location + dateSearchFormatter.string(from: time)
    }
    
    static var shouldStayGroupedWhenSearching: Bool? { true }
    
    static func sortSectionsByThisParameter<T>(_ lhs: T, _ rhs: T) -> Bool? where T : Comparable {
        let lhsModel = lhs as! StudentStatus
        let rhsModel = rhs as! StudentStatus
        return lhsModel.time > rhsModel.time
    }
    
    /// Location and status of student, formatted as "Signed In - Room 123" or "Signed In to Period 4 - Room 123"
    let location : String
    /// Time that the status was recorded
    let time : Date
}
