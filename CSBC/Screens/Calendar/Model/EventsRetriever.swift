//
//  EventsRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 8/3/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Firebase


///If local data is less than 1 hour old, then thats returned, if not, then database data is returned if is less than 1 hour old, otherwise, a GCF is invoked, which takes about 15 seconds to return. 
class EventsRetriever {
    private let preferences = UserDefaults.standard
    let completion : (Set<EventsModel>, Bool) -> Void
    
    
    init(completion: @escaping (Set<EventsModel>, Bool) -> Void) {
        self.completion = completion
    }
    

    func retrieveEventsArray(forceReturn : Bool = false, forceRefresh: Bool = false) {
        if forceRefresh {
            print("Events Data is being force refreshed")
            requestEventsDataFromFirebase()
        } else if forceReturn {
            print("Events Data is being force returned")
            let json = preferences.value(forKey:"eventsArray") as? Data
            let setToReturn = try? PropertyListDecoder().decode(Set<EventsModel>.self, from: json ?? Data())
            completion(setToReturn ?? [], false)
        } else if let eventsArrayTimeString = preferences.string(forKey: "eventsArrayTime"),
            let json = preferences.value(forKey:"eventsArray") as? Data,
            let eventsSet = try? PropertyListDecoder().decode(Set<EventsModel>.self, from: json) { //If both events values are defined
                print("Attempting to retrieve stored Events data.")
                let eventsArrayTime = eventsArrayTimeString.toDateWithTime()! + 3600 //Time one hour in future
                if eventsArrayTime < Date() {
                    completion(eventsSet, true)
                    print("Events data found, but is old. Will refresh online.")
                    requestEventsDataFromFirebase()
                } else {
                    print("Up to date events data found")
                    completion(eventsSet, false)
                }
        } else {
            print("No Events data found in UserDefaults. Looking online.")
            requestEventsDataFromFirebase()
        }
    }
    
    
    func requestEventsDataFromFirebase() {
        Database.database().reference().child("Calendars").observeSingleEvent(of: .value) { snapshot in
            guard let eventsArrayDict = snapshot.childSnapshot(forPath: "eventsArray").value as? [[String:String]] else { return }
            print("Events array updated, new data returned")
            self.completion(EventsDataParser.parseJSON(eventsArrayDict), false)
        }
    }
}
