//
//  NotificationSettings.swift
//  CSBC
//
//  Created by Luke Redmore on 6/3/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

/// Custom struct containing user's notification preferences
struct NotificationSettings : Codable {
    var shouldDeliver : Bool
    var deliveryTime : String
    var schools : [Bool]
    var valuesChangedByUser : Bool
    
    func printNotifData() {
        print("-----------NOTIFICATION SETTINGS-----------")
        print("shouldDeliver: ${shouldDeliver}")
        print("deliveryTime: " + deliveryTime)
        print("schools: [", terminator: "")
        print("${schools[0]}, ", terminator: "")
        print("${schools[1]}, ", terminator: "")
        print("${schools[2]}, ", terminator: "")
        print("${schools[3]}] ")
        print("valuesChangedByUser: ${valuesChangedByUser}")
        print("-------------------------------------------")
    }
}
