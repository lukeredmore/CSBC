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
    private let monthDict = ["jan":"01","feb":"02","mar":"03","apr":"04","may":"05","jun":"06","jul":"07","aug":"08","sep":"09","oct":"10","nov":"11","dec":"12"]
    var eventsModelArray : [EventsModel?] = []
    var eventsModelArrayFiltered : [EventsModel?] = []
   
    
    func parseHTMLForEvents (html : String) {
        do {
            var infoOrganizedByEvent : [String] = []
            let doc = try SwiftSoup.parse(html)
            let allPInfo = try doc.select("p").array()
            
            for i in allPInfo.indices {
                let pClass = try allPInfo[i].attr("class")
                if pClass == "desc_trig_outter" {
                    let text = try allPInfo[i].html()
                    infoOrganizedByEvent.append(text)
                }
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            let fmt = DateFormatter()
            fmt.dateFormat = "MMMM dd"
            for n in infoOrganizedByEvent.indices {
                var dateString = String()
                var day = String()
                var month = String()
                var time = String()
                var event = String()
                var schools = String()
                var eventMonth = String()
                
                let eventDoc = try SwiftSoup.parse(infoOrganizedByEvent[n])
                let titleInfo = try eventDoc.select("span").array()
                for i in titleInfo.indices {
                    let tag = try titleInfo[i].attr("itemprop")
                    if tag == "name" {
                        event = try titleInfo[i].text()
                    }
                }
                
                let timeInfo = try eventDoc.select("em").array()
                for i in timeInfo.indices {
                    let classTag = try timeInfo[i].attr("class")
                    if classTag == "date" {
                        day = try timeInfo[i].text()
                    }
                    else if classTag == "month" {
                        let text = try timeInfo[i].text()
                        if monthDict[text] == nil {
                            eventMonth = monthDict[text]!
                        } else {
                            eventMonth = text
                        }
                        month = text.uppercased()
                        
                    }
                    else if classTag == "evcal_time" {
                        var text = try timeInfo[i].text()
                        if text.components(separatedBy: " ")[0] == "(All" {
                            text = "All Day"
                        }
                        time = text
                    }
                    let dataFilterTag = try timeInfo[i].attr("data-filter")
                    if dataFilterTag == "event_type" {
                        let text = try timeInfo[i].text()
                        
                        if schools == "" {
                            schools = text
                        } else {
                            schools = "\(schools) \(text)"
                        }
                        
                    }
                    
                }
                if eventMonth.count == 2 {
                    let originalDateString = "\(eventMonth)/\(day)"
                    let date : Date = formatter.date(from: originalDateString)!
                    dateString = fmt.string(from: date)
                } else {
                    eventMonth = eventMonth.capitalized
                    dateString = "\(eventMonth) \(day)"
                }
                
                let eventToAppend = EventsModel(
                    date: dateString,
                    day: day,
                    month: month,
                    time: time,
                    event: event,
                    schools: schools
                )
                if !eventsModelArray.contains(eventToAppend) {
                    eventsModelArray.append(eventToAppend)
                }
            }
            if eventsModelArray.count > 1 {
                if eventsModelArray[0] != nil {
                    eventsModelArray = eventsModelArray.sorted { $0!.day < $1!.day }
                }
            }
            addObjectArrayToUserDefaults(eventsModelArray)
        } catch { }
    }
    private func addObjectArrayToUserDefaults(_ eventsArray: [EventsModel?]) {
        print("Events array is being added to UserDefaults")
        let dateTimeToAdd = Date().dateStringWithTime()
        UserDefaults.standard.set(try? PropertyListEncoder().encode(eventsArray), forKey: "eventsArray")
        UserDefaults.standard.set(dateTimeToAdd, forKey: "eventsArrayTime")
    }
    
    
    func addToFilteredModelArray(modelsToInclude: [Int]) {
        eventsModelArrayFiltered.removeAll()
        for modelInt in modelsToInclude {
            if !eventsModelArrayFiltered.contains(eventsModelArray[modelInt]) {
                eventsModelArrayFiltered.append(eventsModelArray[modelInt])
            }
        }
        if eventsModelArrayFiltered.count > 1 {
            if eventsModelArrayFiltered[0] != nil {
                eventsModelArrayFiltered = eventsModelArrayFiltered.sorted { $0!.day < $1!.day }
            }
        }
    }
}
