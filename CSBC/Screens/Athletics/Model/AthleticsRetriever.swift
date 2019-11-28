//
//  AthleticsRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 8/4/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import SwiftyJSON

class AthleticsRetriever {
    private let preferences = UserDefaults.standard
    let completion : (Set<AthleticsModel>) -> Void
    let dataParser = AthleticsDataParser()
    
    init(completion: @escaping (Set<AthleticsModel>) -> Void) {
        self.completion = completion
    }
    
    func retrieveAthleticsArray(forceReturn : Bool = false, forceRefresh: Bool = false) {
        if forceRefresh {
            print("Athletics Data is being refreshed")
            getAthleticsDataFromOnline()
        } else if forceReturn {
            print("Athletics Data is being force returned")
            if let json = preferences.value(forKey:"athleticsArray") as? Data {
                print("Force return found an old JSON value")
                let optionalModel = try? PropertyListDecoder().decode(Set<AthleticsModel>.self, from: json)
                return completion(optionalModel ?? [])
            } else {
                print("Force return returned an empty array")
                return completion([])
            }
        } else {
            print("Attempting to retrieve stored Athletics data.")
            if let athleticsArrayTimeString = preferences.string(forKey: "athleticsArrayTime"),
                let json = preferences.value(forKey:"athleticsArray") as? Data,
                let athleticsArray = try? PropertyListDecoder().decode(Set<AthleticsModel>.self, from: json) { //If both values exist
                let athleticsArrayTime = athleticsArrayTimeString.toDateWithTime()! + 3600 //Time one hour in future
                completion(athleticsArray)
                if athleticsArrayTime > Date() {
                    print("Up-to-date Athletics data found, no need to look online.")
                    return
                } else {
                    print("Athletics data found, but is old. Will refresh online.")
                    getAthleticsDataFromOnline()
                }
            } else {
                print("No local Athletics data found in UserDefaults. Looking online.")
                getAthleticsDataFromOnline()
            }
        }
    }
    private func getAthleticsDataFromOnline() {
        print("we are asking for Athletis data")
        var url = URLComponents(string: "https://www.schedulegalaxy.com/api/v1/schools/163/activities")!
        let parameters = ["regular_season", "scrimmage", "post_season", "event"]
        var items = [URLQueryItem]()
        for type in parameters {
            items.append(URLQueryItem(name: "game_types[]", value: type))
        }
        url.queryItems = items
        
        let request =  URLRequest(url: (url.url)!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    print("Athletics Data Received")
                    let athleticsJSON = JSON(data!)
                    self.completion(AthleticsDataParser.parseAthleticsData(json: athleticsJSON))
                } else {
                    print("Error on request to ScheduleGalaxy: ")
                    print(error!)
                    self.retrieveAthleticsArray(forceReturn: true, forceRefresh: false)
                }
            }
        }
        task.resume()
    }
}
