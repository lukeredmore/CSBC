//
//  EventsRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 8/3/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import Alamofire

class EventsRetriever {
    private let preferences = UserDefaults.standard
    
    func retrieveEventsArray(forceReturn : Bool = false, forceRefresh: Bool = false, completion : @escaping ([EventsModel?]) -> Void) {
        if forceRefresh {
            print("Events Data is being force refreshed")
            getEventsDataFromOnline(completion: completion)
        } else if forceReturn {
            print("Events Data is being force returned")
            if let json = preferences.value(forKey:"eventsArray") as? Data {
                print("Force return found an old JSON value")
                let optionalModel = try? PropertyListDecoder().decode([EventsModel?].self, from: json)
                return completion(optionalModel ?? [EventsModel]())
            } else {
                print("Force return returned an empty array")
                return completion([EventsModel]())
            }
        } else {
            print("Attempting to retrieve stored Events data.")
            if let eventsArrayTimeString = preferences.string(forKey: "eventsArrayTime"),
                let json = preferences.value(forKey:"eventsArray") as? Data { //If both events values are defined
                let eventsArrayTime = eventsArrayTimeString.toDateWithTime()! + 3600 //Time one hour in future
                if eventsArrayTime > Date() {
                    print("Up-to-date Events data found, no need to look online.")
                    return completion(try! PropertyListDecoder().decode([EventsModel?].self, from: json))
                } else {
                    print("Events data found, but is old. Will refresh online.")
                    getEventsDataFromOnline(completion: completion)
                }
            } else {
                print("No Events data found in UserDefaults. Looking online.")
                getEventsDataFromOnline(completion: completion)
            }
        }
    }
    private func getEventsDataFromOnline(completion : @escaping ([EventsModel?]) -> Void) {
        print("We are asking for Events data")
        Alamofire.request("https://csbcsaints.org/calendar").responseString(queue: nil, encoding: .utf8) { response in
            if let html = response.result.value, response.error == nil {
                if html.contains("span") {
                    EventsDataParser().parseHTMLForEvents(html: html)
                    self.retrieveEventsArray(forceReturn: false, forceRefresh: false, completion: completion)
                }
            } else {
                print("Error on request to CSBCSaints.org: ")
                print(response.error!)
                self.retrieveEventsArray(forceReturn: true, forceRefresh: false, completion: completion)
            }
        }
    }
}
