//
//  Schools.swift
//  CSBC
//
//  Created by Luke Redmore on 8/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

enum Schools : Int {
    case seton
    case john
    case saints
    case james
    
    var shortName: String {
        switch self {
        case .seton:
            return "Seton"
        case .john:
            return "St. John's"
        case .saints:
            return "All Saints"
        case .james:
            return "St. James"
        }
    }
    
    var fullName: String {
        switch self {
        case .seton:
            return "Seton Catholic Central"
        case .john:
            return "St. John School"
        case .saints:
            return "All Saints School"
        case .james:
            return "St. James School"
        }
    }
    
    var singleString: String {
        switch self {
        case .seton:
            return "Seton"
        case .john:
            return "John"
        case .saints:
            return "Saints"
        case .james:
            return "James"
        }
    }
    
    var rawValue: Int {
        switch self {
        case .seton:
            return 0
        case .john:
            return 1
        case .saints:
            return 2
        case .james:
            return 3
        }
    }
}
