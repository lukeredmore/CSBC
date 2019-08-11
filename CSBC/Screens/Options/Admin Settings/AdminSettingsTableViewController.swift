//
//  AdminSettingsTableViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 5/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase

///TableViewDelegate controlling segues to composers and day override
class AdminSettingsTableViewController: UITableViewController, DayOverriddenDelegate {

    @IBOutlet weak var dayLabel: UILabel!
    let notificationController = NotificationController()
    var usersSchool : String? = nil
    var originalDay : Int? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        notificationController.reinit()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if usersSchool != nil {
                let notificationSenderVC = ComposerViewController.instantiate(
                    school: usersSchool)
                self.present(notificationSenderVC, animated: true, completion: nil)
            }
        case 1:
            if originalDay != nil, dayLabel.text != "" {
                let dayOverrideVC = ModalPickerViewController.instantiateForDayOverride(
                    delegate: self,
                    dayToShow: originalDay!)
                self.present(dayOverrideVC, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func adminDidOverrideDay(day: Int) {
        if originalDay != nil, usersSchool != nil {
            var dictToStore = UserDefaults.standard.dictionary(forKey: "dayScheduleOverrides") as? [String:Int] ?? ["Seton":0,"John":0,"Saints":0,"James":0]
            dictToStore[usersSchool!] = day - originalDay! + dictToStore[usersSchool!]!
            
            print("Adding day schedule override to database")
            Database.database().reference().child("DayScheduleOverrides").updateChildValues(dictToStore) {
                (error, reference) in
                if error != nil {
                    print("Error adding day schedule override to databae: ", error!)
                } else {
                    UserDefaults.standard.set(dictToStore, forKey: "dayScheduleOverrides")
                    print("Override added")
                    self.dayLabel.text = "\(day)"
                    self.originalDay = day
                    self.notificationController.reinit()
                }
            }
        }
    }
    
}
