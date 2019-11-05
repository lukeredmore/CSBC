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
    private var eventsArray : Set<EventsModel> {
        guard let json = UserDefaults.standard.value(forKey:"eventsArray") as? Data else { return [] }
        return (try? PropertyListDecoder().decode(Set<EventsModel>.self, from: json)) ?? []
    }
    private var athleticsArray : Set<AthleticsModel> {
        guard let json = UserDefaults.standard.value(forKey:"athleticsArray") as? Data else { return [] }
        return (try? PropertyListDecoder().decode(Set<AthleticsModel>.self, from: json)) ?? []
    }
    private var schoolSelectedString : String {
        (Schools(rawValue: UserDefaults.standard.integer(forKey:"schoolSelected")) ?? .seton).ssString
    }
    
    private lazy var eventsRetriever = EventsRetriever() { (_, type) in
        print("Events data of type \(type) has been updated for Today")
    }
    private lazy var athleticsRetriever = AthleticsRetriever { (athleticsArray) in
        print("Athletics data of has been updated for Today")
    }
    
    init() {
        eventsRetriever.retrieveEventsArray()
        athleticsRetriever.retrieveAthleticsArray()
    }
    
    
    //MARK: Parse schedules for TodayVC
    func events(forDate date : Date) -> Set<EventsModel>? {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        
        let setToReturn = eventsArray.filter {
            $0.date == dateComponents && ($0.schools?.contains(schoolSelectedString) ?? false || $0.schools == "" )
        }
        
        return setToReturn.count > 0 ? setToReturn : nil
    }
    func athletics(forDate date : Date) -> Set<AthleticsModel>? {
        
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        
        let setToReturn = athleticsArray.filter {
            $0.date == dateComponents
        }
        
        return setToReturn.count > 0 ? setToReturn : nil
    }
}
