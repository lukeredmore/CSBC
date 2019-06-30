//
//  EventsParsing.swift
//  CSBC
//
//  Created by Luke Redmore on 3/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UIKit
import SwiftSoup


class EventsParsing {
    let monthDict = ["jan":"01","feb":"02","mar":"03","apr":"04","may":"05","jun":"06","jul":"07","aug":"08","sep":"09","oct":"10","nov":"11","dec":"12"]
    var eventTitleArray : [String] = []
    var eventDateArray : [String] = []
    var eventmonthDict : [String] = []
    var eventTimeArray : [String] = []
    var eventArray : [[String:String]] = [[:]]
    var filteredEventArray : [[String:String]] = [[:]]
    var filteredEventArrayNoDuplicates : [[String:String]] = [[:]]
    var infoOrganizedByEvent : [String] = []
    var storedSchoolsToShow : [Bool] = []
    var i = 0
    
    init() {
    }
    
    func parseHTMLForEvents (html : String) {
        do {
            infoOrganizedByEvent = []
            let doc = try SwiftSoup.parse(html)
            let allPInfo = try doc.select("p").array()
            
            for i in 0..<allPInfo.count {
                let pClass = try allPInfo[i].attr("class")
                if pClass == "desc_trig_outter" {
                    let text = try allPInfo[i].html()
                    infoOrganizedByEvent.append(text)
                }
                
            }
            
            i = 0
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            let fmt = DateFormatter()
            fmt.dateFormat = "MMMM dd"
            eventArray = [[:]]
            for n in 0..<infoOrganizedByEvent.count {
                var tempGroup : [String:String] = [:]
                var schoolsIncluded = ""
                var eventDate = ""
                var eventMonth = ""
                let eventDoc = try SwiftSoup.parse(infoOrganizedByEvent[n])
                let titleInfo = try eventDoc.select("span").array()
                for i in 0..<titleInfo.count {
                    let tag = try titleInfo[i].attr("itemprop")
                    if tag == "name" {
                        let text = try titleInfo[i].text()
                        tempGroup["event"] = text
                    }
                }
                let timeInfo = try eventDoc.select("em").array()
                for i in 0..<timeInfo.count {
                    let classTag = try timeInfo[i].attr("class")
                    if classTag == "date" {
                        let text = try timeInfo[i].text()
                        eventDate = text
                        tempGroup["day"] = text
                    }
                    else if classTag == "month" {
                        let text = try timeInfo[i].text()
                        if monthDict[text] == nil {
                            eventMonth = monthDict[text]!
                        } else {
                            eventMonth = text
                        }
                        tempGroup["month"] = text.uppercased()
                        
                    }
                    else if classTag == "evcal_time" {
                        var text = try timeInfo[i].text()
                        if text.components(separatedBy: " ")[0] == "(All" {
                            text = "All Day"
                        }
                        tempGroup["time"] = text
                    }
                    let dataFilterTag = try timeInfo[i].attr("data-filter")
                    if dataFilterTag == "event_type" {
                        let text = try timeInfo[i].text()
                        
                        if schoolsIncluded == "" {
                            schoolsIncluded = text
                        } else {
                            schoolsIncluded = "\(schoolsIncluded) \(text)"
                        }
                        
                    }
                    
                }
                var modifiedDateString = ""
                if eventMonth.count == 2 {
                    let originalDateString = "\(eventMonth)/\(eventDate)"
                    let date : Date = formatter.date(from: originalDateString)!
                    modifiedDateString = fmt.string(from: date)
                } else {
                    eventMonth = eventMonth.capitalized
                    modifiedDateString = "\(eventMonth) \(eventDate)"
                }
                
                tempGroup["date"] = modifiedDateString
                tempGroup["schools"] = schoolsIncluded
                
                eventArray.append(tempGroup)
                
            }
            if eventArray[0] == [:] {
                eventArray.remove(at: 0)
            }
            userDidSelectSchools()
            
        } catch {}
    }
    
    func userDidSelectSchools() {
        //print(storedSchoolsToShow)
        filteredEventArray = [[:]]
        var showSeton : String = "x"
        var showJohn : String = "x"
        var showSaints : String = "x"
        var showJames : String = "x"
        if storedSchoolsToShow.count != 4 {
            storedSchoolsToShow = [true, true, true, true]
        }
        if storedSchoolsToShow[0] == true {
            showSeton = "Seton"
        }
        if storedSchoolsToShow[1] == true {
            showJohn = "John"
        }
        if storedSchoolsToShow[2] == true{
            showSaints = "Saints"
        }
        if storedSchoolsToShow[3] == true {
            showJames = "James"
        }
        for i in 0..<eventArray.count {
            if eventArray[i]["schools"]!.contains(showSeton) || eventArray[i]["schools"]!.contains(showJohn) || eventArray[i]["schools"]!.contains(showSaints) || eventArray[i]["schools"]!.contains(showJames) || eventArray[i]["schools"] == "" {
                filteredEventArray.append(eventArray[i])
            }
        }
        if filteredEventArray[0] == [:] {
            filteredEventArray.remove(at: 0)
        }
        
        //Mark - Remove beginning of calendar duplicates
        if filteredEventArray.count > 0 {
            filteredEventArrayNoDuplicates = [filteredEventArray[0]]
            if filteredEventArray.count > 1 {
                //            print("remove dups")
                for i in 1..<filteredEventArray.count {
                    if filteredEventArrayNoDuplicates.contains(filteredEventArray[i]) {}
                    else {
                        //                    print("tryna populate")
                        filteredEventArrayNoDuplicates.append(filteredEventArray[i])
                    }
                }
                //print(filteredEventArrayNoDuplicates)
            }
        } else {
            filteredEventArrayNoDuplicates = [["date":"","day":"","month":"","time":"","event":"","schools":""]]
        }
        

        
        
    }

}
