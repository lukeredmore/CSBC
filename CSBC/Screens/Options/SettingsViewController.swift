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
    @IBOutlet weak private var deliverNotificationsSwitch: UISwitch!
    @IBOutlet weak private var deliveryTimeLabel: UILabel!
    @IBOutlet weak private var deliveryTimeCell: UITableViewCell!
    @IBOutlet private var settingsSwitch: [UISwitch]!
    @IBOutlet weak private var copyrightLabel: UILabel!
    @IBOutlet weak private var versionLabel: UILabel!
    
    private let userDefaults = UserDefaults.standard
    private var fmt : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        fmt.amSymbol = "AM"
        fmt.pmSymbol = "PM"
        return fmt
    }
    
    private var deliveryTimeSegue : UIStoryboardSegue?
    private var reportIssueSegue : UIStoryboardSegue?
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        copyrightLabel.text = "© \(Date().yearString()) Catholic Schools of Broome County"
        
        #if DEBUG
        versionLabel.text = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)a"
        #else
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        #endif
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getNotificationPreferences()
    }
    override func viewWillDisappear(_ animated: Bool) {
        if !settingsSwitch[0].isOn && !settingsSwitch[1].isOn && !settingsSwitch[2].isOn && !settingsSwitch[3].isOn {
            userDefaults.set(true, forKey: "showAllSchools")
            NotificationController.notificationSettings.shouldDeliver = false
        } else {
            userDefaults.set(settingsSwitch[4].isOn, forKey: "showAllSchools")
            NotificationController.notificationSettings.shouldDeliver = deliverNotificationsSwitch.isOn
        }
        if !NotificationController.notificationSettings.shouldDeliver || NotificationController.notificationSettings.deliveryTime != "7:00 AM" || NotificationController.notificationSettings.schools != [true, true, true, true] || NotificationController.notificationSettings.valuesChangedByUser {
            NotificationController.notificationSettings.valuesChangedByUser = true
        }
    }
    
    
    private func getNotificationPreferences() {
        for i in 0..<4 { //Schools switches
            settingsSwitch[i].isOn = NotificationController.notificationSettings.schools[i]
        }
        
        let showAllSchools = userDefaults.value(forKey: "showAllSchools") as! Bool?
        settingsSwitch[4].isOn = showAllSchools ?? true
        
        deliverNotificationsSwitch.isOn = NotificationController.notificationSettings.shouldDeliver
        deliveryTimeCell.isHidden = !NotificationController.notificationSettings.shouldDeliver
        
        deliveryTimeLabel.text = NotificationController.notificationSettings.deliveryTime //what time should they be
        
        tableView.reloadData()
    }
    
    
    //MARK: Button Listeners
    @IBAction private func settingsSwitchToggled(_ sender: Any) { //school switches
        NotificationController.notificationSettings.valuesChangedByUser = true
        
        let tag = (sender as AnyObject).tag - 1
        NotificationController.notificationSettings.schools[tag] = settingsSwitch[tag].isOn
        
        if (!settingsSwitch[0].isOn && !settingsSwitch[1].isOn && !settingsSwitch[2].isOn && !settingsSwitch[3].isOn) || (settingsSwitch[0].isOn && settingsSwitch[1].isOn && settingsSwitch[2].isOn && settingsSwitch[3].isOn) { //if all off or on
            settingsSwitch[4].setOn(true, animated: true)
            userDefaults.set(true, forKey: "showAllSchools")
        }
        
    }
    @IBAction private func showAllSchoolsSwitchToggled(_ sender: Any) { //turn on showAllSchools if schools are all off or all on
        if (!settingsSwitch[0].isOn && !settingsSwitch[1].isOn && !settingsSwitch[2].isOn && !settingsSwitch[3].isOn && !settingsSwitch[4].isOn) || (settingsSwitch[0].isOn && settingsSwitch[1].isOn && settingsSwitch[2].isOn && settingsSwitch[3].isOn) {
            settingsSwitch[4].setOn(true, animated: true)
            userDefaults.set(true, forKey: "showAllSchools")
        }
    }
    @IBAction private func notificationOptInToggled(_ sender: Any) { //deliver notiications switch
        NotificationController.notificationSettings.valuesChangedByUser = true

        deliveryTimeCell.isHidden = !deliverNotificationsSwitch.isOn
        NotificationController.notificationSettings.shouldDeliver = deliverNotificationsSwitch.isOn
    }
    
    
    //MARK: Time Entered Delegate
    func userDidSelectTime(timeToShow: Date) {
        NotificationController.notificationSettings.valuesChangedByUser = true
        
        deliveryTimeLabel.text = fmt.string(from: timeToShow)
        NotificationController.notificationSettings.deliveryTime = deliveryTimeLabel.text!
        tableView.reloadData()
        
    }
    
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 && indexPath.row == 1 {
            let setDeliveryTimeVC = ModalPickerViewController.instantiateForTime(
                delegate: self,
                timeToShow: fmt.date(from: NotificationController.notificationSettings.deliveryTime)!)
            self.present(setDeliveryTimeVC, animated: true, completion: nil)
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            SettingsMailDelegate(self).presentMailVC() //working atm
            /*private let reportIssueVC = ComposerViewController.instantiate()
            self.present(reportIssueVC, animated: true, completion: nil)*/
        }
        if indexPath.section == 4 {
            parent!.performSegue(withIdentifier: "AdminSettingsSegue", sender: parent)
        }
    }

    
    
}
