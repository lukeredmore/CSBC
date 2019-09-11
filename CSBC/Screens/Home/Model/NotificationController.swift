//
//  NotificationController.swift
//  CSBC
//
//  Created by Luke Redmore on 5/22/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase
import FirebaseInstanceID

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
            let userDefinedSettingsExist =
                userDefaults.value(forKey: "shouldDeliverNotifications") != nil &&
                    userDefaults.value(forKey: "timeOfNotificationDeliver") != nil &&
                    userDefaults.value(forKey: "showSetonNotifications") != nil &&
                    userDefaults.value(forKey: "showJohnNotifications") != nil &&
                    userDefaults.value(forKey: "showSaintsNotifications") != nil &&
                    userDefaults.value(forKey: "showJamesNotifications") != nil
            
            if let data = UserDefaults.standard.value(forKey:"Notifications") as? Data {
                let notificationSettings = try? PropertyListDecoder().decode(NotificationSettings.self, from: data)
                return notificationSettings!
            } else if userDefinedSettingsExist {
//                print("Notification settings exist in old form, converting to new form")
                let notifs = NotificationSettings(
                    shouldDeliver: userDefaults.bool(forKey: "shouldDeliverNotifications"),
                    deliveryTime: userDefaults.string(forKey: "timeOfNotificationDeliver")!,
                    schools: [
                        userDefaults.bool(forKey: "showSetonNotifications"),
                        userDefaults.bool(forKey: "showJohnNotifications"),
                        userDefaults.bool(forKey: "showSaintsNotifications"),
                        userDefaults.bool(forKey: "showJamesNotifications")
                    ],
                    valuesChangedByUser: true)
                self.userDefaults.set(try? PropertyListEncoder().encode(notifs), forKey: "Notifications")
                userDefaults.removeObject(forKey: "shouldDeliverNotifications")
                userDefaults.removeObject(forKey: "timeOfNotificationDeliver")
                userDefaults.removeObject(forKey: "showSetonNotifications")
                userDefaults.removeObject(forKey: "showJohnNotifications")
                userDefaults.removeObject(forKey: "showSaintsNotifications")
                userDefaults.removeObject(forKey: "showJamesNotifications")
                return notifs
            } else {
//                print("No notification settings exist, creating new one")
                let notificationSettings = NotificationSettings(shouldDeliver: true, deliveryTime: "7:00 AM", schools: [true, true, true, true], valuesChangedByUser: false)
                return notificationSettings
            }
        }
        set {
            print("Notification settings did update:")
            newValue.printNotifData()
            if notificationSettings.schools != newValue.schools {
                print("Schools have been changed, updating push notification topics")
                subscribeToPushNotificationTopics()
            }
            if notificationSettings.deliveryTime != newValue.deliveryTime || notificationSettings.shouldDeliver != newValue.shouldDeliver || notificationSettings.schools != newValue.schools {
                print("Updating local notifications")
                //queueLocalNotifications()
            }
            userDefaults.set(try? PropertyListEncoder().encode(newValue), forKey: "Notifications")
        }
    }
    
    static func subscribeToPushNotificationTopics() {
        let topicArray = ["setonNotifications","johnNotifications","saintsNotifications","jamesNotifications"]
        for i in 0..<4 {
            if notificationSettings.schools[i] {
                Messaging.messaging().subscribe(toTopic: topicArray[i]) { error in
                    if let error = error { print("Error subscribing to topics: \(error)") } else { print("Subscribed to \(topicArray[i])") }
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topicArray[i]) { error in
                    if let error = error { print("Error unsubscribing from topics: \(error)") } else { print("Unsubscribed from \(topicArray[i])") }
                }
            }
            Analytics.setUserProperty("\(notificationSettings.schools[i])", forName: topicArray[i])
        }
    }
}


