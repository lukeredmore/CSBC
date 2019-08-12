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
    func showBannerAlert(withMessage: String)
    func removeBannerAlert()
    func reinitNotifications()
}

/// Checks for snow days and other critical alerts, tells the main screen and updates Firebase
class AlertController {
    weak private var delegate : AlertDelegate? = nil
    private let defaults = UserDefaults.standard
    private var closedData : [String] = []
    private var snowDatesChecked = false
    private var dayOverridesChecked = false
    private var shouldSnowDatesReinit = false
    private var shouldOverridesReinit = false
    
    init(_ delegate : AlertDelegate) {
        self.delegate = delegate
        self.delegate?.removeBannerAlert()
        getSnowDatesAndOverridesAndQueueNotifications()
    }
    
    private func getSnowDatesAndOverridesAndQueueNotifications() {
        Database.database().reference().child("SnowDays").observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let newSnowDays : [String] = value.allValues as! [String]
                if let ogSnowDays : [String] = self.defaults.array(forKey: "snowDays") as? [String] {
                    if newSnowDays.sorted() != ogSnowDays.sorted() {
                        self.defaults.set(newSnowDays.sorted(), forKey: "snowDays")
                        self.shouldSnowDatesReinit = true
                        self.tryToReinit()
                    }
                } else {
                    self.defaults.set(newSnowDays.sorted(), forKey: "snowDays")
                    self.shouldSnowDatesReinit = true
                    self.tryToReinit()
                }
            }
            self.snowDatesChecked = true
        }

        Database.database().reference().child("DayScheduleOverrides").observeSingleEvent(of: .value) { (snapshot) in
            if let newOverrides = snapshot.value as? [String : Int] {
                if let ogOverrides = self.defaults.dictionary(forKey: "dayScheduleOverrides") as? [String:Int] {
                    if newOverrides != ogOverrides {
                        self.defaults.set(newOverrides, forKey: "dayScheduleOverrides")
                        self.shouldOverridesReinit = true
                        self.tryToReinit()
                    }
                } else {
                    self.defaults.set(newOverrides, forKey: "dayScheduleOverrides")
                    self.shouldOverridesReinit = true
                    self.tryToReinit()
                }
            }
            self.dayOverridesChecked = true
        }
    }
    private func tryToReinit() {
        if (snowDatesChecked && dayOverridesChecked && (shouldSnowDatesReinit || shouldOverridesReinit)) {
            print("reinitializing Notifications")
            self.delegate?.reinitNotifications()
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
                            self.delegate?.showBannerAlert(withMessage: self.closedData[0])
                            if self.closedData[0].contains("closed") || self.closedData[0].contains("Closed") {
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
                        if status.contains("Closed") || status.contains("closed") {
                            self.delegate?.showBannerAlert(withMessage: "The Catholic Schools of Broome County are closed today.")
                            self.addSnowDateToDatabase(date: Date())
                        }
                    }
                } else {
                    print("No alerts found")
                    self.delegate?.removeBannerAlert()
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
        if let currentSnowDays : [String] = self.defaults.array(forKey: "snowDays") as? [String] {
            if !currentSnowDays.contains(dateValueString) {
                print("Adding snow day on \(dateValueString) to database")
                Database.database().reference().child("SnowDays").updateChildValues(dateToAddDict) {
                    (error, reference) in
                    if error != nil {
                        print("Error adding snow day to database:", error!)
                    } else {
                        print("Snow day successfully added")
                        self.getSnowDatesAndOverridesAndQueueNotifications()
                    }
                }
            } else {
                print("Snow day on \(dateValueString) already in database")
            }
        }
        
    }
}
