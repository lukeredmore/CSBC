//
//  PublishPushNotifications.swift
//  CSBC
//
//  Created by Luke Redmore on 5/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import Alamofire

protocol PublishPushNotificationsDelegate: class {
    func notificationDidPublishSucessfully()
    func notificationFailedToPublish(error : Error)
}

/// Takes a given notification and publishes it with preconfigured settings and reports to a delegate (the composer)
class PublishPushNotifications {
 
    var messageToSend : String!
    var schoolConditional : String!
    var notificationTitle : String!
    var headers : HTTPHeaders = ["Content-Type":"application/json"]
    weak var delegate : PublishPushNotificationsDelegate?
    
    init(withMessage : String, toSchool : String) {
        self.messageToSend = withMessage
        self.schoolConditional = findConditionalForSchool(school: toSchool)
        
        if Env.isProduction() {
            headers["Authorization"] = PrivateAPIKeys.PRODUCTION_NOTIFICATION_KEY
        } else {
            headers["Authorization"] = PrivateAPIKeys.DEBUG_NOTIFICATION_KEY
        }
    }
    
    func findConditionalForSchool(school : String) -> String {
        switch school {
        case "Seton":
            notificationTitle = "Seton Catholic Central"
            return "setonNotifications"
        case "St. John's":
            notificationTitle = "St. John School"
            return "johnNotifications"
        case "All Saints":
            notificationTitle = "All Saints School"
            return "saintsNotifications"
        case "St. James":
            notificationTitle = "St. James School"
            return "jamesNotifications"
        default:
            notificationTitle = school
            return ""
        }
    }
    
    func sendNotification() {
        let params : [String : Any] =
            [ "notification": [
                "title": notificationTitle,
                "body": "\(self.messageToSend!)",
                "sound": "default"
                ],
                "condition": "'\(self.schoolConditional!)' in topics",
                "priority": "high"
        ]
        Alamofire.request("https://fcm.googleapis.com/fcm/send", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            //print(response)
            if response.error == nil {
                self.delegate?.notificationDidPublishSucessfully()
            } else {
                print("Error sending notification:", response.error!)
                self.delegate?.notificationFailedToPublish(error: response.error!)
            }
        }
        
        
    }
}
