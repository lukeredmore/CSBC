//
//  NotificationController.swift
//  CSBC
//
//  Created by Luke Redmore on 5/22/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging

/// Retrieves user's notification preferences, queues local day notifications, subscribes users to push notifications
class NotificationController {
    private static let userDefaults = UserDefaults.standard
    
    private static var timeFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        fmt.amSymbol = "AM"
        fmt.pmSymbol = "PM"
        return fmt
    }
    private static var dateStringFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt
    }
    private static let dayScheduleLite = DaySchedule()
    
    static var notificationSettings : NotificationSettings {
        get {
            if let data = UserDefaults.standard.value(forKey:"Notifications") as? Data,
                let notificationSettings = try? PropertyListDecoder().decode(NotificationSettings.self, from: data) {
                return notificationSettings
            } else {
                let notifs = NotificationSettings(
                    shouldDeliver: true,
                    schools: [true, true, true, true],
                    notifyFamilyCheckIn: true
                )
                self.userDefaults.set(try? PropertyListEncoder().encode(notifs), forKey: "Notifications")
                return notifs
            }
        }
        set {
            print("Notification settings did update:")
            newValue.printNotifData()
            subscribeToPushNotificationTopics(newValue)
            userDefaults.set(try? PropertyListEncoder().encode(newValue), forKey: "Notifications")
        }
    }
    
    static func subscribeToPushNotificationTopics(_ settings : NotificationSettings = notificationSettings) {
        let topicArray = ["setonNotifications","johnNotifications","saintsNotifications","jamesNotifications"]
        if !settings.shouldDeliver {
            Messaging.messaging().subscribe(toTopic: "notReceivingNotifications") { error in
                if let error = error { print("Error subscribing to topics: \(error)") }
                else { print("Subscribed to notReceivingNotifications") }
            }
        } else {
            Messaging.messaging().unsubscribe(fromTopic: "notReceivingNotifications") { error in
                if let error = error { print("Error unsubscribing from topics: \(error)") }
                else { print("Unsubscribed from notReceivingNotifications") }
            }
        }
        for i in 0..<4 {
            if settings.schools[i] {
                Messaging.messaging().subscribe(toTopic: topicArray[i]) { error in
                    if let error = error { print("Error subscribing to topics: \(error)") }
                    else { print("Subscribed to \(topicArray[i])") }
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topicArray[i]) { error in
                    if let error = error { print("Error unsubscribing from topics: \(error)") }
                    else { print("Unsubscribed from \(topicArray[i])") }
                }
            }
            Analytics.setUserProperty("\(notificationSettings.schools[i])", forName: topicArray[i])
        }
        CovidQuestionnaireNotifications.configure(notifyFamilyCheckIn: settings.notifyFamilyCheckIn)
        
        
        #if DEBUG
        Messaging.messaging().subscribe(toTopic: "debugDevice") { error in
            if let error = error { print("Error subscribing to topics: \(error)") }
            else { print("Subscribed to debugDevice") }
        }
        #else
        Messaging.messaging().unsubscribe(fromTopic: "debugDevice") { error in
            if let error = error { print("Error unsubscribing from topics: \(error)") }
            else { print("Unsubscribed from debugDevice") }
        }
        #endif
    }
}


