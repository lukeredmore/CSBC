//
//  AthleticsData.swift
//  CSBC
//
//  Created by Luke Redmore on 2/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import SwiftyJSON

class AthleticsData {
    let teamAbbreviations = ["V":"Varsity","JV":"JV","7/8TH":"Modified"]
    var gameInfo : [String : String] = [:]
    var gameInfoArray : [[String : String]] = [[:]]
    var gameDates : [String?] = []
    var numberOfDates : [String:Int] = [:]
    var numberOfDatesArray : [Int] = []
    var header = ""
    var rowHeight : [IndexPath : CGFloat] = [:]
    var numberOfDatesSum : [Int] = []
    //var groupedArray : [[[String:String]]] = [[[:]]]
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(AthleticsViewController.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .gray
        
        return refreshControl
    }()
    var firstTimeLoaded = true
    let requestingURL = true
    var athleticsJSON : JSON?
    var groupedArray : [[[String:String]]] = [[[:]]]//[[["time": "7:00 PM", "date": "Wednesday, February 27", "sport": "Basketball", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "Oneonta"]], [["time": "4:30 PM", "date": "Monday, March 25", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "vs.", "opponent": "Maine-Endwell"], ["time": "5:45 PM", "date": "Monday, March 25", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "Maine-Endwell"]], [["time": "4:30 PM", "date": "Tuesday, March 26", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "Elmira(ElmiraExpress)"]], [["time": "5:00 PM", "date": "Thursday, March 28", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "JohnsonCity"], ["time": "5:00 PM", "date": "Thursday, March 28", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "@", "opponent": "JohnsonCity"]], [["time": "4:30 PM", "date": "Friday, March 29", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "WatkinsGlen"]], [["time": "11:00 AM", "date": "Saturday, March 30", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "Ithaca"]], [["time": "4:30 PM", "date": "Monday, April 1", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "ChenangoValley"], ["time": "5:00 PM", "date": "Monday, April 1", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "@Ithaca"], ["time": "7:00 PM", "date": "Monday, April 1", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "@", "opponent": "ChenangoValley"]], [["time": "4:15 PM", "date": "Tuesday, April 2", "sport": "Outdoor", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "Susquehanna"], ["time": "4:15 PM", "date": "Tuesday, April 2", "sport": "Outdoor", "gender": "Girl", "level": "Varsity", "homeGame": "vs.", "opponent": "Susquehanna"], ["time": "4:30 PM", "date": "Tuesday, April 2", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "ChenangoForks"]], [["time": "5:00 PM", "date": "Wednesday, April 3", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "v.Horseheads"]], [["time": "5:00 PM", "date": "Thursday, April 4", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "Maine-Endwell"], ["time": "7:00 PM", "date": "Thursday, April 4", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "@", "opponent": "Maine-Endwell"]], [["time": "4:30 PM", "date": "Friday, April 5", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "WatkinsGlen"], ["time": "4:30 PM", "date": "Friday, April 5", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "SusquehannaValley"], ["time": "4:30 PM", "date": "Friday, April 5", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "vs.", "opponent": "SusquehannaValley"], ["time": "4:30 PM", "date": "Friday, April 5", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "SusquehannaValley"], ["time": "5:00 PM", "date": "Friday, April 5", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "@Corning-PaintedPost"]], [["time": "4:30 PM", "date": "Monday, April 8", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "vs.", "opponent": "Vestal"], ["time": "5:00 PM", "date": "Monday, April 8", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "v.JohnsonCity"], ["time": "5:45 PM", "date": "Monday, April 8", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "Vestal"]], [["time": "4:30 PM", "date": "Tuesday, April 9", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "NotreDame,Elmira"]], [["time": "4:30 PM", "date": "Wednesday, April 10", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "vs.", "opponent": "Windsor"], ["time": "4:30 PM", "date": "Wednesday, April 10", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "Windsor"], ["time": "4:30 PM", "date": "Wednesday, April 10", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "Windsor"], ["time": "5:00 PM", "date": "Wednesday, April 10", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "@Vestal"]], [["time": "4:30 PM", "date": "Thursday, April 11", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "@", "opponent": "WhitneyPoint"], ["time": "5:30 PM", "date": "Thursday, April 11", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "Windsor"]], [["time": "4:00 PM", "date": "Friday, April 12", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "v.OwegoApalachin"], ["time": "4:30 PM", "date": "Friday, April 12", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "vs.", "opponent": "ChenangoForks"], ["time": "4:30 PM", "date": "Friday, April 12", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "ChenangoForks"], ["time": "4:30 PM", "date": "Friday, April 12", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "ChenangoForks"], ["time": "7:00 PM", "date": "Friday, April 12", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "Union-Endicott"]], [["time": "4:30 PM", "date": "Monday, April 15", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "vs.", "opponent": "ChenangoValley"], ["time": "5:45 PM", "date": "Monday, April 15", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "ChenangoValley"]], [["time": "1:00 PM", "date": "Tuesday, April 16", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "Oneonta"], ["time": "1:00 PM", "date": "Tuesday, April 16", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "Oneonta"], ["time": "1:00 PM", "date": "Tuesday, April 16", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "vs.", "opponent": "Oneonta"], ["time": "4:00 PM", "date": "Tuesday, April 16", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "v.Maine-Endwell"], ["time": "7:00 PM", "date": "Tuesday, April 16", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "ChenangoValley"]], [["time": "12:00 PM", "date": "Wednesday, April 17", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "Auburn"], ["time": "12:00 PM", "date": "Wednesday, April 17", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "@", "opponent": "Auburn"], ["time": "1:00 PM", "date": "Wednesday, April 17", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "Oneonta"], ["time": "2:00 PM", "date": "Wednesday, April 17", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "@", "opponent": "PennYan"]], [["time": "4:30 PM", "date": "Thursday, April 18", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "vs.", "opponent": "Norwich"], ["time": "4:30 PM", "date": "Thursday, April 18", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "Norwich"], ["time": "4:30 PM", "date": "Thursday, April 18", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "Norwich"], ["time": "5:00 PM", "date": "Thursday, April 18", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "@Union-Endicott"]], [["time": "6:30 PM", "date": "Monday, April 22", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "ChenangoForks"]], [["time": "4:15 PM", "date": "Tuesday, April 23", "sport": "Outdoor", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "Windsor"], ["time": "4:30 PM", "date": "Tuesday, April 23", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "vs.", "opponent": "ChenangoForks"], ["time": "5:00 PM", "date": "Tuesday, April 23", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "v.Ithaca"], ["time": "5:45 PM", "date": "Tuesday, April 23", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "ChenangoForks"]], [["time": "4:30 PM", "date": "Wednesday, April 24", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "ChenangoValley"], ["time": "4:30 PM", "date": "Wednesday, April 24", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "ChenangoValley"], ["time": "4:30 PM", "date": "Wednesday, April 24", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "@", "opponent": "ChenangoValley"]], [["time": "4:00 PM", "date": "Thursday, April 25", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "@Horseheads"], ["time": "4:30 PM", "date": "Thursday, April 25", "sport": "Outdoor", "gender": "Boy", "level": "Modified", "homeGame": "vs.", "opponent": "Chenango"], ["time": "4:30 PM", "date": "Thursday, April 25", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "Dryden"]], [["time": "4:30 PM", "date": "Friday, April 26", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "Unatego"]], [["time": "4:30 PM", "date": "Monday, April 29", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "SusquehannaValley"], ["time": "4:30 PM", "date": "Monday, April 29", "sport": "Lacrosse", "gender": "Boy", "level": "Modified", "homeGame": "vs.", "opponent": "ChenangoValley"], ["time": "4:30 PM", "date": "Monday, April 29", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "@", "opponent": "SusquehannaValley"], ["time": "5:00 PM", "date": "Monday, April 29", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "Ithaca"], ["time": "5:00 PM", "date": "Monday, April 29", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "NotreDame,Elmira"], ["time": "7:00 PM", "date": "Monday, April 29", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "@", "opponent": "Ithaca"], ["time": "7:15 PM", "date": "Monday, April 29", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "SusquehannaValley"]], [["time": "4:15 PM", "date": "Wednesday, May 1", "sport": "Outdoor", "gender": "Boy", "level": "Modified", "homeGame": "vs.", "opponent": "Binghamton,"], ["time": "4:15 PM", "date": "Wednesday, May 1", "sport": "Outdoor", "gender": "Girl", "level": "Modified", "homeGame": "vs.", "opponent": "Binghamton,"], ["time": "4:30 PM", "date": "Wednesday, May 1", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "@", "opponent": "Windsor"], ["time": "4:30 PM", "date": "Wednesday, May 1", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "Windsor"], ["time": "5:00 PM", "date": "Wednesday, May 1", "sport": "Tennis", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "v.Corning-PaintedPost"]], [["time": "4:30 PM", "date": "Thursday, May 2", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "@", "opponent": "WhitneyPoint"]], [["time": "4:30 PM", "date": "Friday, May 3", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "@", "opponent": "ChenangoForks"], ["time": "4:30 PM", "date": "Friday, May 3", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "vs.", "opponent": "OwegoApalachin"], ["time": "4:30 PM", "date": "Friday, May 3", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "ChenangoForks"], ["time": "4:30 PM", "date": "Friday, May 3", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "ChenangoForks"], ["time": "5:00 PM", "date": "Friday, May 3", "sport": "Lacrosse", "gender": "Boy", "level": "Modified", "homeGame": "@", "opponent": "Ithaca"], ["time": "5:45 PM", "date": "Friday, May 3", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "OwegoApalachin"]], [["time": "11:00 AM", "date": "Saturday, May 4", "sport": "Baseball", "gender": "Boy", "level": "JV", "homeGame": "@", "opponent": "JohnsonCity"], ["time": "11:00 AM", "date": "Saturday, May 4", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "JohnsonCity"], ["time": "3:30 PM", "date": "Saturday, May 4", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "JohnsonCity"]], [["time": "12:00 AM", "date": "Monday, May 6", "sport": "Outdoor", "gender": "Girl", "level": "Modified", "homeGame": "vs.", "opponent": "Johnson"], ["time": "4:30 PM", "date": "Monday, May 6", "sport": "Softball", "gender": "Girl", "level": "JV", "homeGame": "@", "opponent": "Marathon"], ["time": "4:30 PM", "date": "Monday, May 6", "sport": "Lacrosse", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "ChenangoValley"], ["time": "4:30 PM", "date": "Monday, May 6", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "Windsor"], ["time": "null", "date": "Monday, May 6", "sport": "Outdoor", "gender": "Boy", "level": "Modified", "homeGame": "vs.", "opponent": "Binghamton,"]], [["time": "4:15 PM", "date": "Tuesday, May 7", "sport": "Outdoor", "gender": "Girl", "level": "Varsity", "homeGame": "vs.", "opponent": "Chenango"], ["time": "4:15 PM", "date": "Tuesday, May 7", "sport": "Outdoor", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "Chenango"], ["time": "4:30 PM", "date": "Tuesday, May 7", "sport": "Lacrosse", "gender": "Boy", "level": "Modified", "homeGame": "vs.", "opponent": "Windsor"], ["time": "4:30 PM", "date": "Tuesday, May 7", "sport": "Lacrosse", "gender": "Girl", "level": "Varsity", "homeGame": "vs.", "opponent": "WhitneyPoint"], ["time": "4:30 PM", "date": "Tuesday, May 7", "sport": "Lacrosse", "gender": "Girl", "level": "JV", "homeGame": "vs.", "opponent": "Windsor"]], [["time": "4:30 PM", "date": "Wednesday, May 8", "sport": "Baseball", "gender": "Boy", "level": "Varsity", "homeGame": "vs.", "opponent": "Oneonta"]]]
    
    init() {
        
    }
    
    func parseAthleticsData(json : JSON) {
        //print(json)
        var gameInfoArrayTemp : [[String:String]] = [[:]]
        for i in 0..<json["data"].count { //99 {
            let title = "\(json["data"][i]["title"])"
            var titleArray = title.components(separatedBy: " ")
//            if titleArray[0] == "POSTPONED:" {
//                titleArray.remove(at: 0)
//            }
            titleArray.removeLast()
            titleArray.removeLast()
            if titleArray[0].contains("(") { //if each data is formatted correctly
                var homeGame = ""
                var gender = ""
                var opponent = ""
                if titleArray[3] == "@" {
                    homeGame = "@"
                } else {
                    homeGame = "vs."
                }
                if titleArray[0] == "(G)" {
                    gender = "Girl"
                } else {
                    gender = "Boy"
                }
                let level = teamAbbreviations[titleArray[1]]
                var sport = titleArray[2]
                if sport == "Outdoor" {
                    sport = "Track & Field"
                }
                if titleArray.count == 8 {
                    opponent = titleArray[4] + titleArray[5]
                } else if titleArray.count == 9 {
                    opponent = titleArray[4] + titleArray[5] + titleArray[6]
                } else {
                    opponent = titleArray[4]
                }
                let time = "\(json["data"][i]["start_time"])"
                
                
                var dateString = "\(json["data"][i]["date"])"
                dateString = dateString.replacingOccurrences(of: ",", with: "")
                let months = ["Jan":"01", "Feb":"02", "Mar":"03", "Apr":"04", "May":"05", "Jun":"06", "Jul":"07", "Aug":"08", "Sep":"09", "Oct":"10", "Nov":"11", "Dec":"12"]
                var dateArray = dateString.components(separatedBy: " ")
                dateArray[0] = months[dateArray[0]]!
                let formatter = DateFormatter()
                formatter.dateFormat = "MM dd yyyy"
                let date = formatter.date(from: "\(dateArray[0]) \(dateArray[1]) \(dateArray[2])")
                formatter.dateFormat = "EEEE, MMMM d"
                dateString = formatter.string(from: date!)
                
                gameInfo = ["homeGame" : homeGame, "gender" : gender, "level" : level, "sport" : sport, "opponent" : opponent, "time" : time, "date" : dateString] as! [String : String]
                gameInfoArrayTemp.append(gameInfo)
                if i == 0 && gameInfoArrayTemp[0] == [:] {//}&& firstTimeLoaded == true {
                    gameInfoArrayTemp.remove(at: i)
                }
            } else {
                print("Error in parsing '\(title)'")
            }
            //            print("title array/ game info array")
            //            print(titleArray)
            //            print(gameInfoArrayTemp)
        }
        
        self.gameInfoArray = gameInfoArrayTemp
        while gameInfoArray.first == [:] {
            gameInfoArray.removeFirst()
        }
        //print(gameInfoArray)
        collateDates()
        
        
    }
    
    func collateDates() {
        var i = 0
        var gameDatesTemp : [String] = []
        var numberOfDatesTemp : [String : Int] = [:]
        var numberOfDatesArrayTemp : [Int] = []
        var loop = true
        while i < gameInfoArray.count {
            let dateToBeat = gameInfoArray[i]["date"]
            var n = i
            loop = true
            while loop == true {
                n += 1
                if n < gameInfoArray.count {
                    if dateToBeat == gameInfoArray[n]["date"] {
                        loop = true
                    } else {
                        loop = false
                    }
                } else {
                    loop = false
                }
            }
            gameDatesTemp.append(dateToBeat!) //3-25
            numberOfDatesTemp[dateToBeat!] = n - i
            numberOfDatesArrayTemp.append(n-i)
            i = n
        }
        //        print(numberOfDatesTemp)
        //        print(gameDatesTemp)
        //        print(numberOfDatesArrayTemp)
        self.numberOfDates = numberOfDatesTemp
        self.gameDates = gameDatesTemp
        self.numberOfDatesArray = numberOfDatesArrayTemp
        prepareDatesForTableView()
        
        
    }
    
    func prepareDatesForTableView() {
        groupedArray = [[[:]]]
        numberOfDatesSum = [numberOfDatesArray[0]-1]
        for i in 1..<numberOfDatesArray.count {
            numberOfDatesSum.append(numberOfDatesArray[i] + numberOfDatesSum[i-1])
        }
        
        
        var tempGroup = gameInfoArray[0..<(numberOfDatesSum[0]+1)]
        groupedArray.append(Array(tempGroup))
        //print(tempGroup)
        for i in 1..<numberOfDatesSum.count {
            tempGroup = gameInfoArray[(numberOfDatesSum[i-1]+1)..<(numberOfDatesSum[i]+1)]
            groupedArray.append(Array(tempGroup))
        }
        //if firstTimeLoaded == true {
        groupedArray.remove(at: 0)
        //}
    }
}
