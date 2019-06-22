//
//  NotificationSettings.swift
//  CSBC
//
//  Created by Luke Redmore on 6/3/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

struct NotificationSettings : Codable {
    var shouldDeliver : Bool
    var deliveryTime : String
    var schools : [Bool]
    var valuesChangedByUser : Bool
}
