//
//  TodayDataParser.swift
//  CSBC
//
//  Created by Luke Redmore on 8/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

///Retrieves events and athletics data, parses it, and activates pager when ready. Also parses full data into single days for TodayVC
class TodayDataParser {
    let delegate : TodayParserDelegate!
    let athleticsParser = AthleticsDataParser()
    
    var eventsArray : [EventsModel?] = []
    
    var eventsReady = false
    var athleticsReady = false
    
    
    init(delegate: TodayParserDelegate) {
        self.delegate = delegate
        getSchedulesToSendToToday()
    }
    
    
    //MARK: Retrieve schedules
    func getSchedulesToSendToToday() {
        EventsRetriever().retrieveEventsArray { (eventsArray) in
            self.eventsArray = eventsArray
            self.eventsReady = true
            self.tryToStartupPager()
        }
        if athleticsParser.athleticsModelArray.count > 0 {
            print("using old athletics data")
            tryToStartupPager()
        } else {
            print("getting new athletics data")
            getAthleticsData()
        }
    }
    func getAthleticsData() {
        let parameters = ["game_types" : ["regular_season", "scrimmage", "post_season", "event"]]
        Alamofire.request("https://www.schedulegalaxy.com/api/v1/schools/163/activities", method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Athletics Data Received")
                let athleticsJSON : JSON = JSON(response.result.value!)
                self.athleticsParser.parseAthleticsData(json: athleticsJSON)
                self.athleticsReady = true
                self.tryToStartupPager()
            }
            
        }
    }
    func tryToStartupPager() {
        if eventsReady && athleticsReady {
            delegate.startupPager()
        }
    }
    
    
    //MARK: Parse schedules for TodayVC
    func events(forDate date : Date) -> [EventsModel] {
        var allEventsToday : [EventsModel] = []
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM dd"
        let dateShownForCalendar = fmt.string(from: date)
        for i in 0..<eventsArray.count {
            if let event = eventsArray[i] {
                if event.date == dateShownForCalendar {
                    allEventsToday.append(event)
                    print("At leaset one event is today")
                }
                
            }
        }
        if allEventsToday.count == 0 {
            print("There are no events today")
            return allEventsToday
        }
        
        //Filter for schoolSelected
        var filteredEventsForSchoolsToday : [EventsModel] = []
        for i in 0..<allEventsToday.count {
            if allEventsToday[i].schools.contains(delegate.schoolSelected.ssString) || allEventsToday[i].schools == "" {
                filteredEventsForSchoolsToday.append(allEventsToday[i])
            }
        }
        return filteredEventsForSchoolsToday
    }
    func athletics(forDate date : Date) -> AthleticsModel? {
        var allAthleticsToday : AthleticsModel? = nil
        let athleticsDateFormatter = DateFormatter()
        athleticsDateFormatter.dateFormat = "MMMM dd"
        let monthDayDateString = athleticsDateFormatter.string(from: date)
        for dateWithEvents in athleticsParser.athleticsModelArray {
            if dateWithEvents.date.contains(monthDayDateString) {
                allAthleticsToday = dateWithEvents
            }
        }
        return allAthleticsToday
    }
}
