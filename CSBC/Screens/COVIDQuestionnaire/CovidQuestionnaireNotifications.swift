//
//  CovidQuestionnaireNotifications.swift
//  CSBC
//
//  Created by Luke Redmore on 8/2/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import NotificationCenter

class CovidQuestionnaireNotifications {
    
    
    static func configure(notifyStaffCheckIn: Bool, notifyFamilyCheckIn: Bool) {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        print("Removed all pending local notification requests")
        
        if CovidViewController.showCovidCheckIn {
            if (notifyFamilyCheckIn) {
                let content = UNMutableNotificationContent()
                content.title = "Time to check in!"
                content.body = "Parents and families, if you haven't already, please tap here to complete your child(ren)'s COVID-19 check-in for the upcoming week."
                
                // Configure the recurring date.
                var dateComponents = DateComponents()
                dateComponents.calendar = Calendar.current
                
                        dateComponents.weekday = 1
                        dateComponents.hour = 17
                        dateComponents.minute = 30  // 5:30 PM Sundays
                
//                dateComponents.weekday = 3
//                dateComponents.hour = 12
//                dateComponents.minute = 44
                
                // Create the trigger as a repeating event.
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents, repeats: true)
                // Create the request
                let identifier = "familyCheckInNotif" + String(Int.random(in: 100000 ..< 999999))
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content, trigger: trigger)
                
                // Schedule the request with the system.
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("Registered for Family COVID-19 Check-In Notifications")
                    }
                }
            }
            if (notifyStaffCheckIn) {
                let content = UNMutableNotificationContent()
                content.title = "Time to check in!"
                content.body = "Faculty and staff, if you haven't already, please tap here to complete your COVID-19 check-in. It must be completed 30 minutes before your shift or first class each day."
                
                for count in 2..<7 {
                    
                    // Configure the recurring date.
                    var dateComponents = DateComponents()
                    dateComponents.calendar = Calendar.current
                    
                    dateComponents.weekday = count
                    dateComponents.hour = 6
                    dateComponents.minute = 45  // 6:45 AM Weekdays
                    
                    
                    // Create the trigger as a repeating event.
                    let trigger = UNCalendarNotificationTrigger(
                        dateMatching: dateComponents, repeats: true)
                    // Create the request
                    let identifier = "staffCheckInNotif" + String(Int.random(in: 100000 ..< 999999))
                    let request = UNNotificationRequest(identifier: identifier,
                                                        content: content, trigger: trigger)
                    
                    // Schedule the request with the system.
                    notificationCenter.add(request) { (error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            print("Registered for Staff COVID-19 Check-In Notifications on weekday \(count)")
                        }
                    }
                    
                }
            }
            
            
        }
    }
    
}
