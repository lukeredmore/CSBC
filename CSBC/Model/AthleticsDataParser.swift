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
    let teamAbbreviations = ["V":"Varsity","JV":"JV","7/8TH":"Modified"]
    let months = ["Jan":"01", "Feb":"02", "Mar":"03", "Apr":"04", "May":"05", "Jun":"06", "Jul":"07", "Aug":"08", "Sep":"09", "Oct":"10", "Nov":"11", "Dec":"12"]
    var athleticsModelArray : [AthleticsModel] = []
    var athleticsModelArrayFiltered : [AthleticsModel] = []
    
    init() {}
    
    func parseAthleticsData(json : JSON) {
        var modelListToReturn : [AthleticsModel] = []
        var dateToBeat = "\(json["data"][0]["date"])"
        var currentDate = dateToBeat
        var dateString : String = ""
        var n = 0
        print(dateToBeat)
        while n < json["data"].count {
            var homeGameList : [String] = []
            var genderList : [String] = []
            var levelList : [String] = []
            var sportList : [String] = []
            var opponentList : [String] = []
            var timeList : [String] = []
            while ((currentDate == dateToBeat) && (n < json["data"].count)) {
                let title = "\(json["data"][n]["title"])"
                var titleArray = title.components(separatedBy: " ")
//                if titleArray[0] == "POSTPONED:" {
//                    titleArray.remove(at: 0)
//                }
                titleArray.removeLast()
                titleArray.removeLast()
                if titleArray[0].contains("(") { //if each data is formatted correctly
                    if titleArray[3] == "@" {
                        homeGameList.append("@")
                    } else {
                        homeGameList.append("vs.")
                    }
                    if titleArray[0] == "(G)" {
                        genderList.append("Girl")
                    } else {
                        genderList.append("Boy")
                    }
                    levelList.append(teamAbbreviations[titleArray[1]] ?? "")
                    var sport = titleArray[2]
                    if sport == "Outdoor" {
                        sport = "Track & Field"
                    }
                    sportList.append(sport)
                    if titleArray.count == 8 {
                        opponentList.append(titleArray[4] + titleArray[5])
                    } else if titleArray.count == 9 {
                        opponentList.append(titleArray[4] + titleArray[5] + titleArray[6])
                    } else {
                        opponentList.append(titleArray[4])
                    }
                    timeList.append("\(json["data"][n]["start_time"])")
                    currentDate = "\(json["data"][n+1]["date"])"
                    dateString = "\(json["data"][n]["date"])".replacingOccurrences(of: ",", with: "")
                    var dateArray = dateString.components(separatedBy: " ")
                    dateArray[0] = months[dateArray[0]]!
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM dd yyyy"
                    let date = formatter.date(from: "\(dateArray[0]) \(dateArray[1]) \(dateArray[2])")
                    formatter.dateFormat = "EEEE, MMMM d"
                    dateString = formatter.string(from: date!)
                } else {
                    print("Error in parsing '\(title)'")
                }
                n += 1
                
            }
            dateToBeat = currentDate
            print("adding new model for \(dateString)")
            let modelToAppend = AthleticsModel(homeGame: homeGameList, gender: genderList, level: levelList, sport: sportList, opponent: opponentList, time: timeList, date: dateString)
            modelListToReturn.append(modelToAppend)
            athleticsModelArray = modelListToReturn
        }
    }
    
    func addToFilteredModelArray(modelsToInclude: [Int], indicesToInclude: [Int]) {
        athleticsModelArrayFiltered.removeAll()
        for modelInt in 0..<modelsToInclude.count {
            let modelToAppend = AthleticsModel(
                homeGame: [athleticsModelArray[modelsToInclude[modelInt]].homeGame[indicesToInclude[modelInt]]],
                gender: [athleticsModelArray[modelsToInclude[modelInt]].gender[indicesToInclude[modelInt]]],
                level: [athleticsModelArray[modelsToInclude[modelInt]].level[indicesToInclude[modelInt]]],
                sport: [athleticsModelArray[modelsToInclude[modelInt]].sport[indicesToInclude[modelInt]]],
                opponent: [athleticsModelArray[modelsToInclude[modelInt]].opponent[indicesToInclude[modelInt]]],
                time: [athleticsModelArray[modelsToInclude[modelInt]].time[indicesToInclude[modelInt]]],
                date: athleticsModelArray[modelsToInclude[modelInt]].date)
            athleticsModelArrayFiltered.append(modelToAppend)
            
        }
    }
    
}
