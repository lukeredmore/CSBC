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
    let completion : (Set<EventsModel>, CSBCTableDataType) -> Void
    let dataParser = EventsDataParser()
    
    static var eventsURL : URL! {
        #if DEBUG
        return URL(string: "https://us-central1-csbc-f4e43.cloudfunctions.net/retrieveEventsArray")
        #else
        return URL(string: "https://us-central1-csbcprod.cloudfunctions.net/retrieveEventsArray")
        #endif
    }
    
    init(completion: @escaping (Set<EventsModel>, CSBCTableDataType) -> Void) {
        self.completion = completion
    }
    
    
    
    
    func retrieveEventsArray(forceReturn : Bool = false, forceRefresh: Bool = false) {
        if forceRefresh {
            print("Events Data is being force refreshed")
            completion(dataParser.eventsModelArray, .dummy)
            EventsRetriever.tryToRequestEventsFromGCF(forceRefresh: true)
            requestEventsDataFromFirebase()
        } else if forceReturn {
            print("Events Data is being force returned")
            if let json = preferences.value(forKey:"eventsArray") as? Data {
                print("Force return found an old JSON value")
                completion((try? PropertyListDecoder().decode(Set<EventsModel>.self, from: json)) ?? [], .complete)
            } else {
                print("Force return returned an empty array")
                completion([], .complete)
            }
        } else {
            print("Attempting to retrieve stored Events data.")
            if let eventsArrayTimeString = preferences.string(forKey: "eventsArrayTime"), let json = preferences.value(forKey:"eventsArray") as? Data, let eventsSet = try? PropertyListDecoder().decode(Set<EventsModel>.self, from: json) { //If both events values are defined

                let eventsArrayTime = eventsArrayTimeString.toDateWithTime()! + 3600 //Time one hour in future
                if eventsArrayTime < Date() {
                    completion(eventsSet, .dummy)
                    print("Events data found, but is old. Will refresh online.")
                    requestEventsDataFromFirebase()
                } else {
                    print("Up to date events data found")
                    completion(eventsSet, .complete)
                }
            } else {
                completion([], .dummy)
                print("No Events data found in UserDefaults. Looking online.")
                requestEventsDataFromFirebase()
            }
        }
    }
    
    
    func requestEventsDataFromFirebase() {
        Database.database().reference().child("Calendars").observeSingleEvent(of: .value) { snapshot in
            guard let eventsArrayUpdating = snapshot.childSnapshot(forPath: "eventsArrayUpdating").value as? String,
            let eventsArrayDict = snapshot.childSnapshot(forPath: "eventsArray").value as? [[String:String]] else { return }
            if eventsArrayUpdating == "true" {
                print("Events array is currently updating, waiting to return updated value")
                self.completion(self.dataParser.parseJSON(eventsArrayDict), .dummy)
                Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
                    self.requestEventsDataFromFirebase()
                }
            } else {
                print("Events array updated, new data returned")
                self.completion(self.dataParser.parseJSON(eventsArrayDict), .complete)
            }
        }
    }
    
    static func tryToRequestEventsFromGCF(forceRefresh : Bool = false) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        Database.database().reference().child("Calendars/eventsArrayTime").observeSingleEvent(of: .value) { snapshot in
            if let eventsArrayTimeString = snapshot.value as? String,
                let eventsArrayTime = dateFormatter.date(from: eventsArrayTimeString),
                let dateInOneHour = Calendar.current.date(byAdding: .hour, value: 1, to: eventsArrayTime),
                (Date() < dateInOneHour && !forceRefresh) {
                print("Existing firebase data is okay")
            } else {
                print("Firebase data needs to be replaced")
                requestEventsDataFromGCF()
            }
        }
    }
    static func requestEventsDataFromGCF() {
        print("We are asking for Events data")
        let task = URLSession.shared.dataTask(with: eventsURL, completionHandler: eventsDataGCFRequestCompletionHandler)
        Database.database().reference().child("Calendars/eventsArrayUpdating").setValue("true")
        task.resume()
    }
    static func eventsDataGCFRequestCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
        DispatchQueue.main.async {
            if let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                error == nil, data != nil {
                print("Athletics Data Updated in Firebase")
            } else {
                print(error ?? "nil")
            }
        }
    }
}
