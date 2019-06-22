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

class NotificationController {
    
    let userDefaults = UserDefaults.standard
    var timeFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        fmt.amSymbol = "AM"
        fmt.pmSymbol = "PM"
        return fmt
    }
    var timeFormatterIn24H : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt
    }
    var timeComponents : [Int] = []
//    let schoolsNotifications = ["showSetonNotifications","showJohnNotifications","showSaintsNotifications","showJamesNotifications"]
//    var notif12HTimeString = "7:00 AM"//Get time of notif deliver
//    var notifTimeAsDate : Date!
//    var notif24HTimeString = "07:00"
    var notificationSettings : NotificationSettings!
    
    
    init() {
        //print("initialized")
        notificationSettings = defineNotificationSettings()
        
    }
    
    func reinit() {
        notificationSettings = nil
        notificationSettings = defineNotificationSettings()
    }
    
    func queueNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        if notificationSettings.shouldDeliver {
            print("Notifications queuing")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            
            let notifTimeAsDate = timeFormatter.date(from: notificationSettings.deliveryTime) //Get time of notif deliver as date
            let notif24HTimeString = timeFormatterIn24H.string(from: notifTimeAsDate!) //rewrite in 24h
            print(notif24HTimeString)
            let timeComponentsStrings = notif24HTimeString.components(separatedBy: ":") //convert to components
            print(timeComponentsStrings)
            for i in timeComponentsStrings {
                timeComponents.append(Int(i)!)
            }
            print(timeComponents)
            
            let daySchedule = DaySchedule(forSeton: notificationSettings.schools[0], forJohn: notificationSettings.schools[1], forSaints: notificationSettings.schools[2], forJames: notificationSettings.schools[3])
            var allSchoolDays : [String] = daySchedule.dateDayDictArray
            while formatter.date(from: allSchoolDays.first!)! < Date() { //Remove past dates
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
                
                if notificationSettings.schools[0] && !daySchedule.restrictedDatesForHS.contains(formatter.date(from: date)!) {
                    if let dayOfCycle = daySchedule.dateDayDict["Seton"]![date] {
                        notificationContent1 = "Day \(dayOfCycle) at Seton, "
                    }
                }
                if notificationSettings.schools[1] && !daySchedule.restrictedDatesForES.contains(formatter.date(from: date)!) {
                    if let dayOfCycle = daySchedule.dateDayDict["St. John's"]![date] {
                        notificationContent2 = "Day \(dayOfCycle) at St. John's, "
                    }
                }
                if notificationSettings.schools[2] && !daySchedule.restrictedDatesForES.contains(formatter.date(from: date)!) {
                    if let dayOfCycle = daySchedule.dateDayDict["All Saints"]![date] {
                        notificationContent3 = "Day \(dayOfCycle) at All Saints, "
                    }
                }
                if notificationSettings.schools[3] && !daySchedule.restrictedDatesForES.contains(formatter.date(from: date)!) {
                    if let dayOfCycle = daySchedule.dateDayDict["St. James"]![date] {
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
                let dateComponents = DateComponents(year: Int(dateArray[2]), month: Int(dateArray[0]), day: Int(dateArray[1]), hour: timeComponents[0], minute: timeComponents[1], second: 00)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                //REQUEST
                let request = UNNotificationRequest(identifier: date, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//                print("Today is \(date). Today is \(notificationContent).")
            }
                    center.getPendingNotificationRequests(completionHandler: { requests in
                        for request in requests {
                            print(request)
                        }
                    })
        } else {
            print("User has declined to receive notifications")
        }
        
    }
    
    func subscribeToTopics() {
        let topicArray = ["setonNotifications","johnNotifications","saintsNotifications","jamesNotifications"]
        for i in 0..<4 {
            if notificationSettings.schools[i] {
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
        }
        
    }
    
    func defineNotificationSettings() -> NotificationSettings! {
        if let data = UserDefaults.standard.value(forKey:"Notifications") as? Data {
            let notificationSettings = try? PropertyListDecoder().decode(NotificationSettings.self, from: data)
            return notificationSettings!
        } else {
            let notificationSettings = NotificationSettings(shouldDeliver: true, deliveryTime: "7:00 AM", schools: [true, true, true, true], valuesChangedByUser: false)
            return notificationSettings
        }
    }
}
