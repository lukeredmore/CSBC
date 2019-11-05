//
//  AthleticsModel.swift
//  CSBC
//
//  Created by Luke Redmore on 3/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

struct AthleticsModel : Codable, Hashable, Comparable {
    static func < (lhs : AthleticsModel, rhs : AthleticsModel) -> Bool {
        return lhs.date < rhs.date
    }
    
    let title : String
    let level : String
    let time : String
    let date : DateComponents
}
