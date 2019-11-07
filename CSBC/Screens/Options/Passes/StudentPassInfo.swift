//
//  StudentPassInfo.swift
//  CSBC
//
//  Created by Luke Redmore on 11/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

struct StudentPassInfo : Searchable {
    static func sortSectionsByThisParameter<T: Comparable>(_ lhs: T, _ rhs: T) -> Bool? {
        let lhsModel = lhs as! StudentPassInfo
        let rhsModel = rhs as! StudentPassInfo
        return lhsModel.gradeLevel > rhsModel.gradeLevel
    }
    
    var groupIntoSectionsByThisParameter: AnyHashable? { gradeLevel }
    
    var sectionTitle: String? { "Grade \(gradeLevel)" }
    
    var searchElements: String { "\(name) \(gradeLevel) \(currentStatus.location)" }
    
    static var shouldStayGroupedWhenSearching: Bool? { true }
    
    static func < (lhs: StudentPassInfo, rhs: StudentPassInfo) -> Bool {
        lhs.name < rhs.name
    }
    
    let name : String
    let gradeLevel : Int
    let currentStatus : StudentStatus
    let previousStatuses : [StudentStatus]
    
}

struct StudentStatus : Codable, Hashable {
    /// Location and status of student, formatted as "Signed In - Room 123" or "Signed In to Period 4 - Room 123"
    let location : String
    /// Time that the status was recorded
    let time : Date
}
