//
//  SettingsContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit


class SettingsContainerViewController: UIViewController{//, TimeEnteredDelegate {

    let userDefaults = UserDefaults.standard
    var schoolSelected : String? = nil
    let schools = ["Seton","St. John's","All Saints","St. James"]
    let schoolsNotifications = ["showSetonNotifications","showJohnNotifications","showSaintsNotifications","showJamesNotifications"]
    weak var delegate : SchoolSelectedDelegate?
    let fmt = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        var i = 0
        let notificationSettings = defineNotificationSettings()
        while schoolSelected == nil && i < 4 {
            if notificationSettings.schools[i] {
                schoolSelected = schools[i]
            }
            i += 1
        }
        if schoolSelected == nil {
            schoolSelected = "Seton"
        }
        print("attmpetimng to store school of \(schoolSelected!)")
        delegate?.storeSchoolSelected(schoolSelected: self.schoolSelected!)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "SetDeliveryTimeSegue":
            let childVC = segue.destination as! SetDeliveryTimeViewController
            childVC.delegate = children.last as? TimeEnteredDelegate
        case "ReportIssueSegue":
            let childVC = segue.destination as! ComposerViewController
            childVC.eventCalled = .reportIssue
        default:
            break
        }
    }
    
    

}
