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


class EventsDataParser {
    
    var eventsModelArray = [EventsModel?]() //set by Calendar vc
    private(set) var eventsModelArrayFiltered = [EventsModel?]()
    
    
    func parseHTMLForEvents(fromString htmlString : String) {
        eventsModelArray.removeAll()
        guard let eventArrayElements = try? SwiftSoup.parse(htmlString).select("#evcal_list .eventon_list_event").array()
            else { return }
        
        for event in eventArrayElements {
            guard let cell = try? event.select(".desc_trig_outter").first()
                else { print("No parseable cell could be found here. Continuing on."); continue }
            
            //Required parameters
            guard
                let eventTitle = try? cell.select(".evcal_event_title").first()?.text(),
                let day = try? cell.select(".evo_start .date").first()?.text(),
                let dayInt = Int(day)
                else { print("One or more of the required parameters cannot be found. Continuing on."); continue }
            
            //Optional parameters
            let schools = try? cell.select(".ett1").first()?.text().replacingOccurrences(of: "Schools:", with: "")
            var timeString = try? cell.select(".evcal_time").first()?.text().uppercased()
            if timeString != nil, timeString!.contains("(ALL DAY") {
                timeString = "All Day"
            }
            
            
            let dateComponents = DateComponents(
                year: Calendar.current.component(.year, from: Date()),
                month: Calendar.current.component(.month, from: Date()),
                day: dayInt)
            
            
            let eventToAppend = EventsModel(
                event: eventTitle,
                date: dateComponents,
                time: timeString,
                schools: schools)
            
            if !eventsModelArray.contains(eventToAppend) {
                eventsModelArray.append(eventToAppend)
            }

        }
        if eventsModelArray.count > 1, eventsModelArray[0] != nil {
            eventsModelArray = eventsModelArray.sorted { $0!.date.day! < $1!.date.day! }
        }
        addObjectArrayToUserDefaults(eventsModelArray)
    }
    private func addObjectArrayToUserDefaults(_ eventsArray: [EventsModel?]) {
        print("Events array is being added to UserDefaults")
        let dateTimeToAdd = Date().dateStringWithTime()
        UserDefaults.standard.set(try? PropertyListEncoder().encode(eventsArray), forKey: "eventsArray")
        UserDefaults.standard.set(dateTimeToAdd, forKey: "eventsArrayTime")
    }
    
    
    func setFilteredModelArray(toArray filteredArray: [EventsModel?]) {
        eventsModelArrayFiltered.removeAll()
        eventsModelArrayFiltered = filteredArray
        if eventsModelArrayFiltered.count > 1 && eventsModelArrayFiltered[0] != nil {
            eventsModelArrayFiltered = eventsModelArrayFiltered.sorted { $0!.date.day! < $1!.date.day! }
        }
    }
}

