//
//  SettingsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import FirebaseMessaging
import Firebase
import MessageUI

class SettingsViewController: UITableViewController, TimeEnteredDelegate, MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var deliverNotificationsSwitch: UISwitch!
    @IBOutlet weak var deliveryTimeLabel: UILabel!
    @IBOutlet weak var deliveryTimeCell: UITableViewCell!
    @IBOutlet var settingsSwitch: [UISwitch]!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    let userDefaults = UserDefaults.standard
    let schools = ["Seton","St. John's","All Saints","St. James"]
    let schoolsNotifications = ["showSetonNotifications","showJohnNotifications","showSaintsNotifications","showJamesNotifications","showAllSchools"]
    var fmtYear : DateFormatter {
        let fmtYear = DateFormatter()
        fmtYear.dateFormat = "yyyy"
        return fmtYear
    }
    var fmt : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        fmt.amSymbol = "AM"
        fmt.pmSymbol = "PM"
        return fmt
    }
    let topicArray = ["setonNotifications","johnNotifications","saintsNotifications","jamesNotifications"]
    var notificationSettings : NotificationSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationSettings = defineNotificationSettings()
        let currentYear = fmtYear.string(from: Date())
        copyrightLabel.text = "© \(currentYear) Catholic Schools of Broome County"
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNotificationPreferences()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        notificationSettings.schools = [settingsSwitch[0].isOn, settingsSwitch[1].isOn, settingsSwitch[2].isOn, settingsSwitch[3].isOn]
        notificationSettings.deliveryTime = deliveryTimeLabel.text!
        if settingsSwitch[0].isOn == false && settingsSwitch[1].isOn == false && settingsSwitch[2].isOn == false && settingsSwitch[3].isOn == false {
            userDefaults.set(true, forKey: "showAllSchools")
            notificationSettings.shouldDeliver = false
        } else {
            userDefaults.set(settingsSwitch[4].isOn, forKey: "showAllSchools")
            notificationSettings.shouldDeliver = deliverNotificationsSwitch.isOn
        }
        
        if notificationSettings.shouldDeliver != true || notificationSettings.deliveryTime != "7:00 AM" || notificationSettings.schools != [true, true, true, true] || notificationSettings.valuesChangedByUser != false {
            notificationSettings.valuesChangedByUser = true
        }
        userDefaults.set(try? PropertyListEncoder().encode(notificationSettings), forKey: "Notifications")
        
        for i in 0..<4 {
            if settingsSwitch[i].isOn {
                Messaging.messaging().subscribe(toTopic: topicArray[i]) { error in
                    if error == nil {
                        print("Subscribed to \(self.topicArray[i])")
                    } else {
                        print("Error subscribing to \(self.topicArray[i]):", error!)
                    }
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topicArray[i]) { error in
                    if error == nil {
                        print("Unsubscribed from \(self.topicArray[i])")
                    } else {
                        print("Error unsubscribing from \(self.topicArray[i]):", error!)
                    }
                }
            }
            Analytics.setUserProperty("\(settingsSwitch[i].isOn)", forName: self.topicArray[i])
        }
        
        
    }
    
    func getNotificationPreferences() {
        for i in 0..<4 { //Schools switches
            settingsSwitch[i].isOn = notificationSettings.schools[i]
        }
        
        if let showAllSchools:Bool = userDefaults.value(forKey: "showAllSchools") as! Bool? { //should show all schools
            userDefaults.set(settingsSwitch[4].isOn, forKey: "showAllSchools")
            if showAllSchools {
                settingsSwitch[4].isOn = true
            } else {
                settingsSwitch[4].isOn = false
            }
        } else {
            userDefaults.set(true, forKey: "showAllSchools")
            settingsSwitch[4].isOn = true
        }
        
        if notificationSettings.shouldDeliver { //should get notifs
            deliverNotificationsSwitch.isOn = true
            deliveryTimeCell.isHidden = false
        } else {
            deliverNotificationsSwitch.isOn = false
            deliveryTimeCell.isHidden = true
        }
        
        deliveryTimeLabel.text = notificationSettings.deliveryTime //what time should they be
        
        tableView.reloadData()
    }
    
    @IBAction func showAllSchoolsSwitchToggled(_ sender: Any) {
        if (settingsSwitch[0].isOn == false && settingsSwitch[1].isOn == false && settingsSwitch[2].isOn == false && settingsSwitch[3].isOn == false && settingsSwitch[4].isOn == false) || (settingsSwitch[0].isOn && settingsSwitch[1].isOn && settingsSwitch[2].isOn && settingsSwitch[3].isOn) {
            settingsSwitch[4].setOn(true, animated: true)
            userDefaults.set(true, forKey: "showAllSchools")
        }
    }
    
    @IBAction func settingsSwitchToggled(_ sender: Any) {
        notificationSettings.valuesChangedByUser = true
        
        let tag = (sender as AnyObject).tag - 1
        notificationSettings.schools[tag] = settingsSwitch[tag].isOn
        userDefaults.set(try? PropertyListEncoder().encode(notificationSettings), forKey: "Notifications")
        
        if (settingsSwitch[0].isOn == false && settingsSwitch[1].isOn == false && settingsSwitch[2].isOn == false && settingsSwitch[3].isOn == false) || (settingsSwitch[0].isOn && settingsSwitch[1].isOn && settingsSwitch[2].isOn && settingsSwitch[3].isOn) {
            settingsSwitch[4].setOn(true, animated: true)
            userDefaults.set(true, forKey: "showAllSchools")
        }
        
        for i in 0..<4 {
            if settingsSwitch[i].isOn {
                Messaging.messaging().subscribe(toTopic: topicArray[i]) { error in
                    if error == nil {
                        print("Subscribed to \(self.topicArray[i])")
                    } else {
                        print("Error subscribing to \(self.topicArray[i]):", error!)
                    }
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topicArray[i]) { error in
                    if error == nil {
                        print("Unsubscribed from \(self.topicArray[i])")
                    } else {
                        print("Error unsubscribing from \(self.topicArray[i]):", error!)
                    }
                }
            }
            Analytics.setUserProperty("\(settingsSwitch[i].isOn)", forName: self.topicArray[i])
        }
    }
    
    @IBAction func notificationOptInToggled(_ sender: Any) {
        notificationSettings.valuesChangedByUser = true

        if deliverNotificationsSwitch.isOn {
            deliveryTimeCell.isHidden = false
        } else {
            deliveryTimeCell.isHidden = true
        }
        
        notificationSettings.shouldDeliver = !deliveryTimeCell.isHidden
        userDefaults.set(try? PropertyListEncoder().encode(notificationSettings), forKey: "Notifications")
    }
    
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 && indexPath.row == 1 {
            performSegueFromContainer(identifier: "SetDeliveryTimeSegue")
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            presentMailVC()//performSegueFromContainer(identifier: "ReportIssueSegue")
        }
        if indexPath.section == 4 {
            performSegueFromContainer(identifier: "AdminSettingsSegue")
        }
    }
    
    
    
    
    func performSegueFromContainer(identifier : String) {
        let masterVC = parent as! SettingsContainerViewController
        masterVC.performSegue(withIdentifier: identifier, sender: masterVC)
    }
    
    func userDidSelectTime(timeToShow: Date) {
        notificationSettings.valuesChangedByUser = true
        
        deliveryTimeLabel.text = fmt.string(from: timeToShow)
        notificationSettings.deliveryTime = deliveryTimeLabel.text!
        userDefaults.set(try? PropertyListEncoder().encode(notificationSettings), forKey: "Notifications")

        tableView.reloadData()
        
    }
    
    //Mark: Send email
    func presentMailVC() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["lredmore@syrdio.org"])
        mailComposerVC.setSubject("CSBC App User Comment")
        mailComposerVC.setMessageBody("Please give a detailed description of the issue you would like to report or the suggestion you would like to submit:", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send email. Please check your email configuration and try again.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        sendMailErrorAlert.addAction(okButton)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
