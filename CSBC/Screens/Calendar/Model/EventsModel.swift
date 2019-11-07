//
//  EventsModel.swift
//  CSBC
//
//  Created by Luke Redmore on 3/9/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

struct EventsModel: Searchable {
    var groupIntoSectionsByThisParameter: AnyHashable? { nil }
    
    var sectionTitle: String? { nil }
    
    var searchElements: String { "\(event) \(date) \(time ?? "") \(schools ?? "")" }
    
    static var shouldStayGroupedWhenSearching: Bool? { nil }
    
    static func sortSectionsByThisParameter<T>(_ lhs: T, _ rhs: T) -> Bool? where T : Comparable { nil }
    
    
    let event : String
    let date : DateComponents
    let time : String?
    let schools : String?
    
    static func < (lhs : EventsModel, rhs : EventsModel) -> Bool {
        return lhs.date < rhs.date
    }
}


