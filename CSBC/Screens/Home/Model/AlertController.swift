//
//  AlertController.swift
//  CSBC
//
//  Created by Luke Redmore on 6/20/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import Alamofire
import Firebase
import SwiftSoup

protocol AlertDelegate: class {
    var alertMessage : String? { get set }
}

/// Checks for snow days and other critical alerts, tells the main screen and updates Firebase
class AlertController {
    weak private var alertDelegate : AlertDelegate!
    private static let defaults = UserDefaults.standard
    private var closedData : [String] = []
    private static var snowDatesChecked = false
    private static var dayOverridesChecked = false
    
    init(alertDelegate : AlertDelegate) {
        self.alertDelegate = alertDelegate
    }
    
    static func getSnowDatesAndOverridesAndQueueNotifications(completion : ((UIBackgroundFetchResult) -> Void)? = nil) {
        Database.database().reference().child("SnowDays").observeSingleEvent(of: .value) { (snapshot) in
            guard let newSnowDays = (snapshot.value as? NSDictionary)?.allValues as? [String] else {
                self.snowDatesChecked = true
                self.tryToReinit(completion)
                return
            }
            guard let ogSnowDays = self.defaults.array(forKey: "snowDays") as? [String] else {
                self.defaults.set(newSnowDays.sorted(), forKey: "snowDays")
                self.snowDatesChecked = true
                self.tryToReinit(completion)
                return
            }
            if ogSnowDays.sorted() != newSnowDays.sorted() {
                self.defaults.set(newSnowDays.sorted(), forKey: "snowDays")
            }
            self.snowDatesChecked = true
            self.tryToReinit(completion)
        }
        
        Database.database().reference().child("DayScheduleOverrides").observeSingleEvent(of: .value) { (snapshot) in
            guard let newOverrides = snapshot.value as? [String:Int] else {
                self.dayOverridesChecked = true
                self.tryToReinit(completion)
                return
            }
            guard let ogOverrides = self.defaults.dictionary(forKey: "dayScheduleOverrides") as? [String:Int] else {
                self.defaults.set(newOverrides, forKey: "dayScheduleOverrides")
                self.dayOverridesChecked = true
                self.tryToReinit(completion)
                return
            }
            if newOverrides != ogOverrides {
                self.defaults.set(newOverrides, forKey: "dayScheduleOverrides")
            }
            self.dayOverridesChecked = true
            self.tryToReinit(completion)
        }
    }
    private static func tryToReinit(_ completion : ((UIBackgroundFetchResult) -> Void)? = nil) {
        if snowDatesChecked && dayOverridesChecked {
            print("Initializing notifications")
            NotificationController.queueLocalNotifications(completion: completion)
        }
    }
    
    func checkForAlert() {
        print("Checking for alert from CSBC site")
        Alamofire.request("https://csbcsaints.org").responseString(queue: nil, encoding: .utf8) { response in
            if let html = response.result.value {
                if html.contains("strong") {
                    do {
                        let doc = try SwiftSoup.parse(html)
                        let element = try doc.select("strong").array()
                        var i = 0
                        while i < element.count {
                            let text = try element[i].text()
                            self.closedData.append(text)
                            i += 1
                        }
                        if self.closedData[0] != "" {
                            print("An alert was found")
                            self.alertDelegate.alertMessage = self.closedData[0]
                            if self.closedData[0].lowercased().contains("closed") {
                                print("Today is a snow day")
                                self.addSnowDateToDatabase(date: Date())
                            }
                        } else {
                            self.checkForAlertFromWBNG()
                        }
                    } catch {}
                } else {
                    self.checkForAlertFromWBNG()
                }
            }
        }
    }
    private func checkForAlertFromWBNG() {
        var districtStatus : String?
        print("Checking for alert from WBNG")
        Alamofire.request("http://ftpcontent6.worldnow.com/wbng/newsticker/closings.html").responseString(queue: nil, encoding: .utf8) { response in
            if let html = response.result.value {
                if html.contains("Catholic") {
                    do {
                        let doc = try SwiftSoup.parse(html)
                        let element = try doc.select("font").array()
                        for i in element.indices {
                            let value = try element[i].text()
                            if value.contains("Catholic") && value.contains("Broome") {
                                districtStatus = try element[i+1].text()
                                break
                            }
                        }
                    } catch {}
                    if let status = districtStatus {
                        if status.lowercased().contains("closed") {
                            self.alertDelegate.alertMessage = "The Catholic Schools of Broome County are closed today."
                            self.addSnowDateToDatabase(date: Date())
                        }
                    }
                } else {
                    print("No alerts found from WBNG")
                    self.alertDelegate.alertMessage = nil
                }
            }
        }
    }
    private func addSnowDateToDatabase(date : Date) {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        let dateValueString = fmt.string(from: date)
        fmt.dateFormat = "MMddyyyy"
        let dateKeyString = fmt.string(from: date)
        let dateToAddDict = [dateKeyString : dateValueString]
        if let currentSnowDays : [String] = UserDefaults.standard.array(forKey: "snowDays") as? [String] {
            if !currentSnowDays.contains(dateValueString) {
                print("Adding snow day on \(dateValueString) to database")
                Database.database().reference().child("SnowDays").updateChildValues(dateToAddDict) {
                    (error, reference) in
                    if error != nil {
                        print("Error adding snow day to database:", error!)
                    } else {
                        print("Snow day successfully added")
                        AlertController.getSnowDatesAndOverridesAndQueueNotifications()
                        PublishPushNotifications.notifyOthersOfDayScheduleUpdate()
                        PublishPushNotifications.sendAlertNotification(withMessage: "The Catholic Schools of Broome County will be closed today, \(dateValueString).")
                    }
                }
            } else {
                print("Snow day on \(dateValueString) already in database")
            }
        }
        
    }
}
