//
//  STEMTableModel.swift
//  CSBC
//
//  Created by Luke Redmore on 1/11/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

struct STEMTableModel : Searchable {
    var groupIntoSectionsByThisParameter : AnyHashable? { location }
    var sectionTitle : String? { location }
    var searchElements : String { "\(location) \(title) \(organization)" }
    static var shouldStayGroupedWhenSearching : Bool? { true }
    static func sortSectionsByThisParameter<T: Comparable>(_ lhs: T, _ rhs: T) -> Bool? {
        let lhsModel = lhs as! STEMTableModel
        let rhsModel = rhs as! STEMTableModel
        return lhsModel.location < rhsModel.location
    }
    static func < (lhs: STEMTableModel, rhs: STEMTableModel) -> Bool { lhs.title < rhs.title }
    
    let title : String
    let location : String
    let organization : String
    let imageIdentifier : String?
    let identifier : String
    let description : String
    let question : String
    let answer : String
    var answered : Bool
}
