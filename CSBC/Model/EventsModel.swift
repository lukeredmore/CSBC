//
//  EventsModel.swift
//  CSBC
//
//  Created by Luke Redmore on 3/9/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

struct EventsModel: Codable, Equatable {
    let date : String
    let day : String
    let month : String
    let time : String
    let event : String
    let schools : String
}
