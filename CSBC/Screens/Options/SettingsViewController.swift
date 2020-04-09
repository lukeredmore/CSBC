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
    @IBOutlet weak var firstAdminSettingsLabel: UILabel!
    @IBOutlet weak var secondAdminSettingsLabel: UILabel!
    
    
    private let userDefaults = UserDefaults.standard
    private var notificationSchool : Int? { UserDefaults.standard.value(forKey: "notificationSchool") as? Int }
    private var passAccess : Bool { UserDefaults.standard.value(forKey: "passAccess") as? Bool ?? false }
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
        configureAdminLabels()
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
        configureAdminLabels()
    }
    private func configureAdminLabels() {
        let SCHOOL_NOTIF_INFO = ["Seton Families", "St. John's Families", "All Saints Families", "St. James Families", "All Users"]
        if notificationSchool != nil && passAccess {
            firstAdminSettingsLabel.text = "View Active Passes"
            secondAdminSettingsLabel.text = "Send A Notification (To \(SCHOOL_NOTIF_INFO[notificationSchool!]))"
        } else if passAccess {
            firstAdminSettingsLabel.text = "View Active Passes"
            secondAdminSettingsLabel.text = ""
        } else if notificationSchool != nil {
            firstAdminSettingsLabel.text = "Send A Notification (To \(SCHOOL_NOTIF_INFO[notificationSchool!]))"
            secondAdminSettingsLabel.text = ""
        } else {
            firstAdminSettingsLabel.text = ""
            secondAdminSettingsLabel.text = ""
        }
    }
    
    private func errorSending(_ error: String) {
        print("Error sending composer result:", error)
        self.alert("An error occurred", message: "The message could not be sent. Please check your connection and try again.")
    }
    
    
    // MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 4, indexPath.row == 0 { //STEM NIGHT
            guard #available(iOS 13.0, *) else {
                alert("Not supported", message: "Please upgrade to iOS 13 to access exclusive STEM Night features.")
                return
            }
            present(STEMNavigationController(), animated: true)
        } else if indexPath.section == 4, indexPath.row == 1 { //REPORT ISSUE
                let reportIssueVC = ComposerViewController(configuration: ComposerViewController.reportIssueConfiguration) { text in
                    IssueReporter.report(text) { error in
                        guard error == nil else { self.errorSending(error!); return }
                        self.alert("Report successfully submitted")
                    }
                }
                present(reportIssueVC, animated: true)
        } else if indexPath.section == 3, indexPath.row == 0, passAccess { //SHOW PASSES
            navigationController?.pushViewController(PassesViewController(), animated: true)
        } else if indexPath.section == 3, indexPath.row == (passAccess ? 1 : 0), self.notificationSchool != nil { //SEND NOTIFICATION
            let notificationVC = ComposerViewController(configuration: ComposerViewController.notificationConfiguration) { text in
                let params : [String : String] = [
                    "message": text,
                    "schoolInt": String(self.notificationSchool!)
                ]
                CustomNetworking.sendAuthenticatedPostRequest(url: APIEndpoints.SEND_ADMIN_NOTIFICATION_FUNCTION_URL, body: params) { response in
                    DispatchQueue.main.async {
                        guard response.status == 200 else { self.errorSending(response.message); return }
                        self.alert("Notification sucessfully sent")
                    }
                }
            }
            present(notificationVC, animated: true)
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 3 else { return super.tableView(tableView, numberOfRowsInSection: section) }
        if notificationSchool != nil && passAccess {
            return 2
        } else if notificationSchool != nil || passAccess {
            return 1
        } else {
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 3 && (notificationSchool != nil || passAccess) {
            return "Admin Settings"
        } else if section == 3 {
            return nil
        } else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
}

