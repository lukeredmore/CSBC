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

class AlertController {
    
    weak var delegate : AlertDelegate? = nil
    let defaults = UserDefaults.standard
    var closedData : [String] = []
    
    init(delegate : AlertDelegate) {
        self.delegate = delegate
    }
    
    func getSnowDatesAndOverridesAndQueueNotifications() {
        var snowDays : [String] = []
        Database.database().reference().child("SnowDays").observe(.childAdded) {
            (snapshot) in
            let snapshotValue = snapshot.value as! String
            snowDays.append(snapshotValue)
            self.defaults.set(snowDays, forKey: "snowDays")
        }
        
        Database.database().reference().child("DayScheduleOverrides").observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                //print(value)
                self.defaults.set(value, forKey: "dayScheduleOverrides")
                self.delegate?.reinitNotifications()
            }
        })
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
    func checkForAlertFromWBNG() {
        var districtStatus : String?
        print("Checking for alert from WBNG")
        Alamofire.request("http://ftpcontent6.worldnow.com/wbng/newsticker/closings.html").responseString(queue: nil, encoding: .utf8) { response in
            if let html = response.result.value {
                if html.contains("Catholic") {
                    do {
                        let doc = try SwiftSoup.parse(html)
                        let element = try doc.select("font").array()
                        for i in 0..<element.count {
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
    func addSnowDateToDatabase(date : Date) {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        let dateValueString = fmt.string(from: date)
        fmt.dateFormat = "MMddyyyy"
        let dateKeyString = fmt.string(from: date)
        let messagesDB = Database.database().reference().child("SnowDays")
        let dateToAddDict = [dateKeyString:dateValueString]
        print("Adding snow day to database")
        messagesDB.updateChildValues(dateToAddDict) {
            (error, reference) in
            if error != nil {
                print("Error adding snow day to database:", error!)
            } else {
                print("Snow day successfully added")
            }
        }
    }
}
