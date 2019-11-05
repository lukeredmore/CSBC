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
    var athleticsModelArray = Set<AthleticsModel>()
    var athleticsModelArrayFiltered = Set<AthleticsModel>()
    
    func parseAthleticsData(json : JSON) {
        var modelListToReturn = Set<AthleticsModel>()
        var n = 0
        while n < json["data"].count {
            var titleArray = "\(json["data"][n]["title"])".components(separatedBy: " ")
            titleArray.removeLast()
            titleArray.removeLast()
            
            guard titleArray[0].contains("(") else { print("Error in parsing '\(titleArray)'"); n += 1; continue }  //if each data is formatted correctly
            var gender : String
            var sport : String
            var homeGame : String
            var opponent : String
            
            gender = titleArray[0] == "(G)" ? "Girl" : "Boy"
            
            sport = titleArray[2]
            var subsequentOffset = 0
            if sport == "Outdoor" {
                sport = "Track & Field"
            } else if sport == "Cross" {
                sport = "Cross Country"
                subsequentOffset = 1
            }
            
            homeGame = titleArray.contains("@") ? "@" : "vs."
            
            opponent = titleArray[(4 + subsequentOffset)..<(titleArray.count-2)]
                .joined()
                .camelCaseToWords()
                .replacingOccurrences(of: "- ", with: "-")
            
            let title = "\(gender)'s \(sport) \(homeGame) \(opponent)"
            let level =  teamAbbreviations[titleArray[1]] ?? ""
            let time = "\(json["data"][n]["start_time"])"
            
            let jsonDateFormatter = DateFormatter()
            jsonDateFormatter.dateFormat = "MMM d, yyyy"
            let date = jsonDateFormatter.date(from: "\(json["data"][n]["date"])")!
            let dateComponents = DateComponents(year: Int(date.yearString()), month: Int(date.monthNumberString()), day: Int(date.dayString()))
            
            let modelToAppend = AthleticsModel(title: title, level: level, time: time, date: dateComponents)
            modelListToReturn.insert(modelToAppend)
            n += 1
            
        }
        athleticsModelArray = modelListToReturn
        addObjectArrayToUserDefaults(athleticsModelArray)
    }
    private func addObjectArrayToUserDefaults(_ athleticsArray: Set<AthleticsModel>) {
        print("Athletics array is being added to UserDefaults")
        let dateTimeToAdd = Date().dateStringWithTime()
        UserDefaults.standard.set(try? PropertyListEncoder().encode(athleticsArray), forKey: "athleticsArray")
        UserDefaults.standard.set(dateTimeToAdd, forKey: "athleticsArrayTime")
    }
}
