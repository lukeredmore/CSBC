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
    private let delegate : TodayParserDelegate!
    
    private var eventsArray : Set<EventsModel> = []
    private var athleticsArray : [AthleticsModel?] = []
    
    private var eventsReady = false
    private var athleticsReady = false
    
    private lazy var eventsRetriever = EventsRetriever(delegate: delegate) { (eventsArray, bool) in
        self.eventsArray = self.eventsArray.union(eventsArray)
        self.eventsReady = true
        self.tryToStartupPager()
    }
    private lazy var athleticsRetriever = AthleticsRetriever { (athleticsArray) in
        self.athleticsArray = athleticsArray
        self.athleticsReady = true
        self.tryToStartupPager()
    }
    
    
    
    init(delegate: TodayParserDelegate) {
        self.delegate = delegate
        getSchedulesToSendToToday()
    }
    
    
    //MARK: Retrieve schedules
    private func getSchedulesToSendToToday() {
        eventsRetriever.retrieveEventsArray()
        athleticsRetriever.retrieveAthleticsArray()
    }
    private func tryToStartupPager() {
        if eventsReady && athleticsReady {
            delegate.startupPager()
        }
    }
    
    
    //MARK: Parse schedules for TodayVC
    func events(forDate date : Date) -> Set<EventsModel>? {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        
        let setToReturn = eventsArray.filter {
        $0.date == dateComponents && ($0.schools?.contains(delegate.schoolSelected.ssString) ?? false || $0.schools == "" )
        }
        
        return setToReturn.count > 0 ? setToReturn : nil
    }
    func athletics(forDate date : Date) -> AthleticsModel? {
        var allAthleticsToday : AthleticsModel? = nil
        let athleticsDateFormatter = DateFormatter()
        athleticsDateFormatter.dateFormat = "MMMM dd"
        let monthDayDateString = athleticsDateFormatter.string(from: date)
        
        for case let dateWithEvents? in athleticsArray {
            if dateWithEvents.date.contains(monthDayDateString) {
                allAthleticsToday = dateWithEvents
            }
        }
        return allAthleticsToday
    }
}
