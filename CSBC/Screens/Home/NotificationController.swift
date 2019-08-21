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
    
    private let userDefaults = UserDefaults.standard
    private var timeFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        fmt.amSymbol = "AM"
        fmt.pmSymbol = "PM"
        return fmt
    }
    private var dateStringFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt
    }
    private let dayScheduleLite = DaySchedule()
    var notificationSettings : NotificationSettings!
    
    
    init() {
        notificationSettings = defineNotificationSettings()
    }
    
    func reinit() {
        notificationSettings = nil
        notificationSettings = defineNotificationSettings()
    }
    
    func queueNotifications(completion : ((UIBackgroundFetchResult) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        if notificationSettings.shouldDeliver && Date() < dateStringFormatter.date(from: dayScheduleLite.endDateString)! { //If date is during school year
            print("Notifications queuing")
            
            var timeComponents : DateComponents
            
            if let notifTimeAsDate = timeFormatter.date(from: notificationSettings.deliveryTime) {
                timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: notifTimeAsDate)
            } else {
                timeComponents = DateComponents(hour: 07, minute: 00, second: 00)
            }
            
            let daySchedule = DaySchedule(forSeton: notificationSettings.schools[0], forJohn: notificationSettings.schools[1], forSaints: notificationSettings.schools[2], forJames: notificationSettings.schools[3])
            var allSchoolDays : [String] = daySchedule.dateDayDictArray
            while dateStringFormatter.date(from: allSchoolDays.first!)! < Date() { //Remove past dates
                allSchoolDays.removeFirst()
            }
            
            //Mark: Setup notification
            for date in allSchoolDays {
                //print(date)
                
                //WHAT
                var notificationContent = ""
                var notificationContent1 = ""
                var notificationContent2 = ""
                var notificationContent3 = ""
                var notificationContent4 = ""
                
                if notificationSettings.schools[0] && !daySchedule.restrictedDatesForHS.contains(dateStringFormatter.date(from: date)!) {
                    if let dayOfCycle = daySchedule.getDayOptional(forSchool: .seton, forDateString: date) {
                        notificationContent1 = "Day \(dayOfCycle) at Seton, "
                    }
                }
                if notificationSettings.schools[1] && !daySchedule.restrictedDatesForES.contains(dateStringFormatter.date(from: date)!) {
                    if let dayOfCycle = daySchedule.getDayOptional(forSchool: .john, forDateString: date) {
                        notificationContent2 = "Day \(dayOfCycle) at St. John's, "
                    }
                }
                if notificationSettings.schools[2] && !daySchedule.restrictedDatesForES.contains(dateStringFormatter.date(from: date)!) {
                    if let dayOfCycle = daySchedule.getDayOptional(forSchool: .saints, forDateString: date) {
                        notificationContent3 = "Day \(dayOfCycle) at All Saints, "
                    }
                }
                if notificationSettings.schools[3] && !daySchedule.restrictedDatesForES.contains(dateStringFormatter.date(from: date)!) {
                    if let dayOfCycle = daySchedule.getDayOptional(forSchool: .james, forDateString: date) {
                        notificationContent4 = "Day \(dayOfCycle) at St. James, "
                    }
                }
                notificationContent = "\(notificationContent1)\(notificationContent2)\(notificationContent3)\(notificationContent4)"
                notificationContent.removeLast()
                notificationContent.removeLast()
                let content = UNMutableNotificationContent()
                content.title = "Good Morning!"
                //content.body = "Today is Day \(dayOfCycle).\(gymDayString)"
                content.body = "Today is \(notificationContent)."
                content.sound = UNNotificationSound.default
                
                //WHEN
                let dateArray = date.components(separatedBy: "/")
                let dateComponents = DateComponents(year: Int(dateArray[2]), month: Int(dateArray[0]), day: Int(dateArray[1]), hour: timeComponents.hour, minute: timeComponents.minute, second: timeComponents.second)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                //REQUEST
                let request = UNNotificationRequest(identifier: date, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                //                print("Today is \(date). Today is \(notificationContent).")
            }
//            center.getPendingNotificationRequests() { requests in
//                for request in requests {
//                    print(request)
//                }
//            }
        } else {
            print("User has declined to receive notifications")
        }
        completion?(UIBackgroundFetchResult.newData)
    }
    
    func subscribeToTopics() {
        let topicArray = ["setonNotifications","johnNotifications","saintsNotifications","jamesNotifications"]
        for i in 0..<4 {
            if notificationSettings?.schools[i] ?? false {
                Messaging.messaging().subscribe(toTopic: topicArray[i]) { error in
                    if error == nil {
                        print("Subscribed to \(topicArray[i])")
                    } else {
                        print(error!)
                    }
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topicArray[i]) { error in
                    if error == nil {
                        print("Unsubscribed from \(topicArray[i])")
                    } else {
                        print(error!)
                    }
                }
            }
            Analytics.setUserProperty("\(notificationSettings?.schools[i] ?? false)", forName: topicArray[i])
        }
    }
    
    private func defineNotificationSettings() -> NotificationSettings {
        let userDefinedSettingsExist =
            userDefaults.value(forKey: "shouldDeliverNotifications") != nil &&
                userDefaults.value(forKey: "timeOfNotificationDeliver") != nil &&
                userDefaults.value(forKey: "showSetonNotifications") != nil &&
                userDefaults.value(forKey: "showJohnNotifications") != nil &&
                userDefaults.value(forKey: "showSaintsNotifications") != nil &&
                userDefaults.value(forKey: "showJamesNotifications") != nil
        
        if userDefinedSettingsExist {
            print("Notification settings exist in old form, converting to new form")
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
        } else if let data = UserDefaults.standard.value(forKey:"Notifications") as? Data {
            print("Notification settings exist in new form")
            let notificationSettings = try? PropertyListDecoder().decode(NotificationSettings.self, from: data)
            return notificationSettings!
        } else {
            print("No notification settings exist, creating new one")
            let notificationSettings = NotificationSettings(shouldDeliver: true, deliveryTime: "7:00 AM", schools: [true, true, true, true], valuesChangedByUser: false)
            return notificationSettings
        }
    }
    
    func storeNotificationSettings(_ settings: NotificationSettings) {
        settings.printNotifData()
        self.notificationSettings = settings
        userDefaults.set(try? PropertyListEncoder().encode(notificationSettings), forKey: "Notifications")
    }
}


