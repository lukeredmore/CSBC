//
//  PublishPushNotifications.swift
//  CSBC
//
//  Created by Luke Redmore on 5/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

/// Takes a given notification and publishes it with preconfigured settings and reports to a delegate (the composer)
class PublishPushNotifications {
    
    private static func conditional(for school : Schools) -> String {
        switch school {
        case .seton:
            return "setonNotifications"
        case .john:
            return "johnNotifications"
        case .saints:
            return "saintsNotifications"
        case .james:
            return "jamesNotifications"
        }
    }
    
    static func send(withMessage message : String, toSchool school : Schools, completion: ((String?) -> Void)? = nil) {
        
        let url = "https://fcm.googleapis.com/fcm/send"
        let params : [String : Any] = [
            "notification": [
                "title": school.fullName,
                "body": "\(message)",
                "sound": "default"
            ],
            "condition": "'\(conditional(for: school))' in topics",
            "priority": "high"
        ]
        guard let request = createURLRequestForPost(urlString: url, data: params) else {
            print("Invalid URLRequest")
            completion?("Invalid URLRequest")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion?(error?.localizedDescription)
            }
        }
        task.resume()
    }
    
    private static func createURLRequestForPost(urlString: String, data: [String : Any?]) -> URLRequest? {
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        
        var apiKey : String
        #if DEBUG
        apiKey = PrivateAPIKeys.DEBUG_NOTIFICATION_KEY
        #else
        apiKey = PrivateAPIKeys.PRODUCTION_NOTIFICATION_KEY
        #endif
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            print("Invalid Data")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        return request
    }
}
