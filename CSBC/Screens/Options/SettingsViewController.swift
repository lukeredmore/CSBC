//
//  SettingsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Controls all settings switches and receives time from datePicker. Updates Firebase through NotificationController
class SettingsViewController: UITableViewController  {
    @IBOutlet weak private var deliverNotificationsSwitch: UISwitch!
    @IBOutlet private var settingsSwitch: [UISwitch]!
    @IBOutlet weak private var copyrightLabel: UILabel! { didSet {
        copyrightLabel.text = "© \(Date().yearString()) Catholic Schools of Broome County"
    }}
    @IBOutlet weak private var versionLabel: UILabel! { didSet {
        versionLabel.text = Bundle.versionString
    } }
    
    private let userDefaults = UserDefaults.standard
    private var userIsATeacher : Bool { UserDefaults.standard.value(forKey: "userIsATeacher") as? Bool ?? false }
    private var userIsAnAdmin : Bool { UserDefaults.standard.value(forKey: "userIsAnAdmin") as? Bool ?? false }
    private var adminSchool : Schools? {
        guard let rawVal = UserDefaults.standard.value(forKey: "adminSchool") as? Int else { return nil }
        return Schools(rawValue: rawVal)
    }
    private var allSchoolsOff : Bool {
        !settingsSwitch[0].isOn && !settingsSwitch[1].isOn && !settingsSwitch[2].isOn && !settingsSwitch[3].isOn
    }
    private var allSchoolsOn : Bool {
        settingsSwitch[0].isOn && settingsSwitch[1].isOn && settingsSwitch[2].isOn && settingsSwitch[3].isOn
    }
    
    
    //MARK: View Control
    override func viewWillAppear(_ animated: Bool) {
        for i in 0..<4 { settingsSwitch[i].isOn = NotificationController.notificationSettings.schools[i] }
        settingsSwitch[4].isOn = userDefaults.value(forKey: "showAllSchools") as? Bool ?? true
        deliverNotificationsSwitch.isOn = NotificationController.notificationSettings.shouldDeliver
    }
    
    
    //MARK: Button Listeners
    @IBAction private func settingsSwitchToggled(_ sender: UIButton?) { //school switches
        guard let tag = sender?.tag else { return }
        NotificationController.notificationSettings.schools[tag - 1] = settingsSwitch[tag - 1].isOn
        showAllSchoolsSwitchToggled(nil)
    }
    @IBAction private func showAllSchoolsSwitchToggled(_ sender: UIButton?) { //Ensures everything isn't off or everything is on
        if allSchoolsOff || allSchoolsOn {
            settingsSwitch[4].setOn(true, animated: true)
        }
        userDefaults.set(settingsSwitch[4].isOn, forKey: "showAllSchools")
        if allSchoolsOff {
            deliverNotificationsSwitch.setOn(false, animated: true)
            NotificationController.notificationSettings.shouldDeliver = false
        }
    }
    @IBAction private func notificationOptInToggled(_ sender: UIButton?) { //deliver notifications switch; turns off when schools are off
        guard !allSchoolsOff else { deliverNotificationsSwitch.setOn(false, animated: true); return }
        NotificationController.notificationSettings.shouldDeliver = deliverNotificationsSwitch.isOn
    }
    
    
    //MARK: Other methods
    func refreshTable() { //Called by container on login state change
        tableView.reloadData()
    }
    private func showComposers(at indexPath : IndexPath) {
        if indexPath.section == 4 && indexPath.row == 0 {
            let reportIssueVC = ComposerViewController(configuration: ComposerViewController.reportIssueConfiguration) { text in
                IssueReporter.report(text) { error in
                    guard error == nil else { errorSending(error!); return }
                    self.alert("Report successfully submitted")
                }
            }
            present(reportIssueVC, animated: true)
        }
        if indexPath.section == 3 && indexPath.row == 1 {
            let notificationVC = ComposerViewController(configuration: ComposerViewController.notificationConfiguration) { text in
                PushNotificationSender.send(withMessage: text, toSchool: self.adminSchool ?? .seton) { error in
                    guard error == nil else { errorSending(error!); return }
                    self.alert("Notification sucessfully sent")
                }
            }
            present(notificationVC, animated: true)
        }
        
        func errorSending(_ error: String) {
            print("Error sending composer result:", error)
            self.alert("An error occurred", message: "The message could not be sent. Please check your connection and try again.")
        }
    }
    
    
    // MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 && indexPath.row == 0 {
            navigationController?.pushViewController(PassesViewController(), animated: true)
        } else { showComposers(at: indexPath) }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 3 else { return super.tableView(tableView, numberOfRowsInSection: section) }
        if userIsAnAdmin {
            return 2
        } else if userIsATeacher {
            return 1
        } else {
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 3 && (userIsAnAdmin || userIsATeacher) {
            return "Admin Settings"
        } else if section == 3 {
            return nil
        } else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
}

