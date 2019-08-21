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
    func notificationFailedToPublish(withError : Error)
}

/// Takes a given notification and publishes it with preconfigured settings and reports to a delegate (the composer)
class PublishPushNotifications {
 
    private var messageToSend : String!
    private var schoolConditional : String!
    private var notificationTitle : String!
    private var headers : HTTPHeaders = ["Content-Type":"application/json"]
    weak var delegate : PublishPushNotificationsDelegate?
    
    init(withMessage : String, toSchool : Schools) {
        self.messageToSend = withMessage
        self.schoolConditional = findConditionalForSchool(school: toSchool)
        
        #if DEBUG
        headers["Authorization"] = PrivateAPIKeys.DEBUG_NOTIFICATION_KEY
        #else
        headers["Authorization"] = PrivateAPIKeys.PRODUCTION_NOTIFICATION_KEY
        #endif
    }
    
    private func findConditionalForSchool(school : Schools) -> String {
        switch school {
        case .seton:
            notificationTitle = "Seton Catholic Central"
            return "setonNotifications"
        case .john:
            notificationTitle = "St. John School"
            return "johnNotifications"
        case .saints:
            notificationTitle = "All Saints School"
            return "saintsNotifications"
        case .james:
            notificationTitle = "St. James School"
            return "jamesNotifications"
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
                self.delegate?.notificationFailedToPublish(withError: response.error!)
            }
        }
        
        
    }
    
    static func notifyOthersOfDayScheduleUpdate() {
        var dataNotifHeaders : HTTPHeaders = ["Content-Type":"application/json"]
        #if DEBUG
        dataNotifHeaders["Authorization"] = PrivateAPIKeys.DEBUG_NOTIFICATION_KEY
        #else
        dataNotifHeaders["Authorization"] = PrivateAPIKeys.PRODUCTION_NOTIFICATION_KEY
        #endif
        let params : [String : Any] = [
        "condition": "'appUser' in topics || 'setonNotifications' in topics",
        "priority": "high",
        "content_available": true
        ]
        
        Alamofire.request("https://fcm.googleapis.com/fcm/send", method: .post, parameters: params, encoding: JSONEncoding.default, headers: dataNotifHeaders).responseJSON { (response) in
            if response.error == nil {
                print("Sucessfully notified users of new data")
            } else {
                print("Error sending data notification:", response.error!)
            }
        }
    }
}
