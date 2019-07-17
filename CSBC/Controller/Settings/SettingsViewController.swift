//
//  SettingsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Controls all settings switches and receives time from datePicker. Updates Firebase through NotificationController
class SettingsViewController: UITableViewController, TimeEnteredDelegate  {
    
    @IBOutlet weak var deliverNotificationsSwitch: UISwitch!
    @IBOutlet weak var deliveryTimeLabel: UILabel!
    @IBOutlet weak var deliveryTimeCell: UITableViewCell!
    @IBOutlet var settingsSwitch: [UISwitch]!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    let userDefaults = UserDefaults.standard
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
    var notificationController = NotificationController()
    var notificationSettings : NotificationSettings!
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationSettings = notificationController.notificationSettings
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
        if !settingsSwitch[0].isOn && !settingsSwitch[1].isOn && !settingsSwitch[2].isOn && !settingsSwitch[3].isOn {
            userDefaults.set(true, forKey: "showAllSchools")
            notificationSettings.shouldDeliver = false
        } else {
            userDefaults.set(settingsSwitch[4].isOn, forKey: "showAllSchools")
            notificationSettings.shouldDeliver = deliverNotificationsSwitch.isOn
        }
        
        if !notificationSettings.shouldDeliver || notificationSettings.deliveryTime != "7:00 AM" || notificationSettings.schools != [true, true, true, true] || notificationSettings.valuesChangedByUser {
            notificationSettings.valuesChangedByUser = true
        }
        notificationController.storeNotificationSettings(notificationSettings)
        notificationController.subscribeToTopics()
    }
    func performSegueFromContainer(identifier : String) {
        let masterVC = parent as! SettingsContainerViewController
        masterVC.performSegue(withIdentifier: identifier, sender: masterVC)
    }
    
    func getNotificationPreferences() {
        for i in 0..<4 { //Schools switches
            settingsSwitch[i].isOn = notificationSettings.schools[i]
        }
        
        let showAllSchools = userDefaults.value(forKey: "showAllSchools") as! Bool?
        settingsSwitch[4].isOn = showAllSchools ?? true
        
        deliverNotificationsSwitch.isOn = notificationSettings.shouldDeliver
        deliveryTimeCell.isHidden = !notificationSettings.shouldDeliver
        
        deliveryTimeLabel.text = notificationSettings.deliveryTime //what time should they be
        
        tableView.reloadData()
    }
    
    
    //MARK: Button Listeners
    @IBAction func settingsSwitchToggled(_ sender: Any) { //school switches
        notificationSettings.valuesChangedByUser = true
        
        let tag = (sender as AnyObject).tag - 1
        notificationSettings.schools[tag] = settingsSwitch[tag].isOn
        notificationController.storeNotificationSettings(notificationSettings)
        
        if (!settingsSwitch[0].isOn && !settingsSwitch[1].isOn && !settingsSwitch[2].isOn && !settingsSwitch[3].isOn) || (settingsSwitch[0].isOn && settingsSwitch[1].isOn && settingsSwitch[2].isOn && settingsSwitch[3].isOn) { //if all off or on
            settingsSwitch[4].setOn(true, animated: true)
            userDefaults.set(true, forKey: "showAllSchools")
        }
        
    }
    @IBAction func showAllSchoolsSwitchToggled(_ sender: Any) { //turn on showAllSchools if schools are all off or all on
        if (!settingsSwitch[0].isOn && !settingsSwitch[1].isOn && !settingsSwitch[2].isOn && !settingsSwitch[3].isOn && !settingsSwitch[4].isOn) || (settingsSwitch[0].isOn && settingsSwitch[1].isOn && settingsSwitch[2].isOn && settingsSwitch[3].isOn) {
            settingsSwitch[4].setOn(true, animated: true)
            userDefaults.set(true, forKey: "showAllSchools")
        }
    }
    @IBAction func notificationOptInToggled(_ sender: Any) { //deliver notiications switch
        notificationSettings.valuesChangedByUser = true

        deliveryTimeCell.isHidden = !deliverNotificationsSwitch.isOn
        notificationSettings.shouldDeliver = deliverNotificationsSwitch.isOn
        
        notificationController.storeNotificationSettings(notificationSettings)
    }
    
    
    //MARK: Time Entered Delegate
    func userDidSelectTime(timeToShow: Date) {
        notificationSettings.valuesChangedByUser = true
        
        deliveryTimeLabel.text = fmt.string(from: timeToShow)
        notificationSettings.deliveryTime = deliveryTimeLabel.text!
        notificationController.storeNotificationSettings(notificationSettings)

        tableView.reloadData()
        
    }
    
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 && indexPath.row == 1 {
            performSegueFromContainer(identifier: "SetDeliveryTimeSegue")
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            let mailDelegate = SettingsViewDelegate(self)
            mailDelegate.presentMailVC()
            //performSegueFromContainer(identifier: "ReportIssueSegue")
        }
        if indexPath.section == 4 {
            performSegueFromContainer(identifier: "AdminSettingsSegue")
        }
    }

    
    
}
