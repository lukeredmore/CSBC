//
//  EventsDataParser.swift
//  CSBC
//
//  Created by Luke Redmore on 3/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UIKit
import SwiftSoup

///Parsers JSON data from EventsRetriever to Set of EventsModel
class EventsDataParser {
    static func parseJSON(_ json : [[String:String]]) -> Set<EventsModel> {
        var eventsModelSet : Set<EventsModel> = []
        for event in json {
            guard let title = event["title"],
                 let date = event["date"] else { continue }
            let dateInts = date.components(separatedBy: "-").map { Int($0)! }
            let eventToInsert = EventsModel(
                event: title,
                date: DateComponents(year: dateInts[0], month: dateInts[1], day: dateInts[2]),
                time: event["time"] == "" || event["time"] == nil ? nil : event["time"],
                schools: event["schools"] == "" || event["schools"] == nil ? nil : event["schools"]
            )
            eventsModelSet.insert(eventToInsert)
        }
        addObjectArrayToUserDefaults(eventsModelSet)
        return eventsModelSet
    }
    private static func addObjectArrayToUserDefaults(_ eventsArray: Set<EventsModel>) {
        print("Events array is being added to UserDefaults")
        let dateTimeToAdd = Date().dateStringWithTime()
        UserDefaults.standard.set(try? PropertyListEncoder().encode(eventsArray), forKey: "eventsArray")
        UserDefaults.standard.set(dateTimeToAdd, forKey: "eventsArrayTime")
    }
}

