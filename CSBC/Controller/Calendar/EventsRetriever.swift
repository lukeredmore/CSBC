//
//  EventsRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 8/3/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Alamofire

class EventsRetriever: NSObject {
    
    let preferences = UserDefaults.standard
    
    func retrieveEventsArray(forceReturn : Bool = false, forceRefresh: Bool = false, callback : @escaping ([EventsModel?]) -> Void) {
        print("Attempting to retrieve stored Events data.")
        if let eventsArrayTimeString = preferences.string(forKey: "eventsArrayTime") {
            let eventsArrayTime = Calendar.current.date(byAdding: .hour, value: 1, to: (eventsArrayTimeString.toDateWithTime())!)
            let json : Data? = preferences.value(forKey:"eventsArray") as? Data
            if forceRefresh {
                print("Events Data is being refreshed")
                getEventsDataFromOnline(callback: callback)
            }
            if (eventsArrayTime != nil && json != nil) {
                if (eventsArrayTime! > Date()) || forceReturn {
                    print("Up-to-date Events data found, no need to look online.")
                    return callback(try! PropertyListDecoder().decode([EventsModel?].self, from: json!))
                } else if (forceReturn) {
                    print("Could not retrieve events data from online")
                    return callback([])
                } else {
                    print("Events data found, but is old. Will refresh online.")
                    getEventsDataFromOnline(callback: callback)
                }
            } else {
                print("No Events data found. Looking online.")
                getEventsDataFromOnline(callback: callback)
            }
        } else {
            print("No Events data found. Looking online.")
            getEventsDataFromOnline(callback: callback)
        }
        
    }
    private func getEventsDataFromOnline(callback : @escaping ([EventsModel?]) -> Void) {
        print("We are asking for Events data")
        Alamofire.request("https://csbcsaints.org/calendar").responseString(queue: nil, encoding: .utf8) { response in
            if let html = response.result.value {
                if html.contains("span") {
                    EventsDataParser().parseHTMLForEvents(html: html)
                    self.retrieveEventsArray(forceReturn: false, forceRefresh: false, callback: callback)
                }
            } else {
                print("Error on request to CSBCSaints.org: ")
                print(response.error)
                self.retrieveEventsArray(forceReturn: true, forceRefresh: false, callback: callback)
            }
        }
    }
}
