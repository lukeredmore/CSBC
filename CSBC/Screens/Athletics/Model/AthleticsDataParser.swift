//
//  AthleticsDataParser.swift
//  CSBC
//
//  Created by Luke Redmore on 2/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import SwiftyJSON

class AthleticsDataParser {
    private let teamAbbreviations = ["V":"Varsity","JV":"JV","7/8TH":"Modified"]
    private let months = ["Jan":"01", "Feb":"02", "Mar":"03", "Apr":"04", "May":"05", "Jun":"06", "Jul":"07", "Aug":"08", "Sep":"09", "Oct":"10", "Nov":"11", "Dec":"12"]
    var athleticsModelArray : [AthleticsModel?] = []
    var athleticsModelArrayFiltered : [AthleticsModel?] = []
    
    func parseAthleticsData(json : JSON) {
        var modelListToReturn : [AthleticsModel] = []
        var dateToBeat = "\(json["data"][0]["date"])"
        var currentDate = dateToBeat
        var dateString : String = ""
        var n = 0
        print(dateToBeat)
        while n < json["data"].count {
            var titleList : [String] = []
            var levelList : [String] = []
            var timeList : [String] = []
            while ((currentDate == dateToBeat) && (n < json["data"].count)) {
                var titleArray = "\(json["data"][n]["title"])".components(separatedBy: " ")
//                if titleArray[0] == "POSTPONED:" {
//                    titleArray.remove(at: 0)
//                }
                titleArray.removeLast()
                titleArray.removeLast()
                if titleArray[0].contains("(") { //if each data is formatted correctly
                    var gender : String
                    var sport : String
                    var homeGame : String
                    var opponent : String
                    
                    if titleArray[0] == "(G)" {
                        gender = "Girl"
                    } else {
                        gender = "Boy"
                    }
                    
                    sport = titleArray[2]
                    if sport == "Outdoor" {
                        sport = "Track & Field"
                    }
                    
                    if titleArray[3] == "@" {
                        homeGame = "@"
                    } else {
                        homeGame = "vs."
                    }
                    
                    if titleArray.count == 8 {
                        opponent = titleArray[4] + titleArray[5]
                    } else if titleArray.count == 9 {
                        opponent = titleArray[4] + titleArray[5] + titleArray[6]
                    } else {
                        opponent = titleArray[4]
                    }
                    opponent = opponent.camelCaseToWords()
                    
                    titleList.append("\(gender)'s \(sport) \(homeGame) \(opponent)")
                    levelList.append(teamAbbreviations[titleArray[1]] ?? "")
                    timeList.append("\(json["data"][n]["start_time"])")
                    
                    let jsonDateFormatter = DateFormatter()
                    jsonDateFormatter.dateFormat = "MMM d, yyyy"
                    let modelDateFormatter = DateFormatter()
                    modelDateFormatter.dateFormat = "EEEE, MMMM d"
                    dateString = modelDateFormatter.string(from:
                        jsonDateFormatter.date(from:
                            "\(json["data"][n]["date"])"
                            )!
                    )

                    if (n < json["data"].count-1) {
                        currentDate = "\(json["data"][n + 1]["date"]))"
                    } else {
                        currentDate = "nil"
                    }
                } else {
                    print("Error in parsing '\(titleArray)'")
                }
                n += 1
                
            }
            dateToBeat = currentDate
            let modelToAppend = AthleticsModel(title: titleList, level: levelList, time: timeList, date: dateString)
            modelListToReturn.append(modelToAppend)
        }
        athleticsModelArray = modelListToReturn
        addObjectArrayToUserDefaults(athleticsModelArray)
    }
    private func addObjectArrayToUserDefaults(_ athleticsArray: [AthleticsModel?]) {
        print("Athletics array is being added to UserDefaults")
        let dateTimeToAdd = Date().dateStringWithTime()
        UserDefaults.standard.set(try? PropertyListEncoder().encode(athleticsArray), forKey: "athleticsArray")
        UserDefaults.standard.set(dateTimeToAdd, forKey: "athleticsArrayTime")
    }
    
    func addToFilteredModelArray(modelsToInclude: [Int], indicesToInclude: [Int]) {
        athleticsModelArrayFiltered.removeAll()
        if athleticsModelArray.count > 0 {
            if athleticsModelArray[0] != nil {
                for modelInt in modelsToInclude {
                    let modelToAppend = AthleticsModel(
                        title: [athleticsModelArray[modelsToInclude[modelInt]]!.title[indicesToInclude[modelInt]]],
                        level: [athleticsModelArray[modelsToInclude[modelInt]]!.level[indicesToInclude[modelInt]]],
                        time: [athleticsModelArray[modelsToInclude[modelInt]]!.time[indicesToInclude[modelInt]]],
                        date: athleticsModelArray[modelsToInclude[modelInt]]!.date)
                    athleticsModelArrayFiltered.append(modelToAppend)
                }
            }
        }
    }
    
    
}
