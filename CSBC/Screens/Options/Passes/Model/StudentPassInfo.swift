//
//  StudentPassInfo.swift
//  CSBC
//
//  Created by Luke Redmore on 11/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation


protocol StudentPassInfo : Searchable {
    var name : String { get }
    var gradeLevel : Int { get }
    var currentStatus : StudentStatus { get }
    var previousStatuses : [StudentStatus] { get }

}

struct SignedOutStudentPassInfo : StudentPassInfo {
    var name: String
    var gradeLevel: Int
    var currentStatus: StudentStatus
    var previousStatuses: [StudentStatus]
    let location : String
    let time : Date
    
    var groupIntoSectionsByThisParameter: AnyHashable? { nil }
    
    var sectionTitle: String? { nil }
    
    var searchElements: String { "\(name) \(gradeLevel) \(currentStatus.location)" }
    
    static var shouldStayGroupedWhenSearching: Bool? { nil }
    
    static func sortSectionsByThisParameter<T>(_ lhs: T, _ rhs: T) -> Bool? where T : Comparable { nil }
    
    static func < (lhs: SignedOutStudentPassInfo, rhs: SignedOutStudentPassInfo) -> Bool {
        lhs.currentStatus.time < rhs.currentStatus.time
    }
    


}

struct AllStudentPassInfo : StudentPassInfo {
    static func sortSectionsByThisParameter<T: Comparable>(_ lhs: T, _ rhs: T) -> Bool? {
        let lhsModel = lhs as! AllStudentPassInfo
        let rhsModel = rhs as! AllStudentPassInfo
        return lhsModel.gradeLevel > rhsModel.gradeLevel
    }
    
    var groupIntoSectionsByThisParameter: AnyHashable? { gradeLevel }
    
    var sectionTitle: String? { "Grade \(gradeLevel)" }
    
    var searchElements: String { "\(name) \(gradeLevel) \(currentStatus.location)" }
    
    static var shouldStayGroupedWhenSearching: Bool? { true }
    
    static func < (lhs: AllStudentPassInfo, rhs: AllStudentPassInfo) -> Bool {
        lhs.name < rhs.name
    }
    
    let name : String
    let gradeLevel : Int
    let currentStatus : StudentStatus
    let previousStatuses : [StudentStatus]
    
}
