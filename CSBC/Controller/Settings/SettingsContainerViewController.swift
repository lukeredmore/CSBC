//
//  SettingsContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit


class SettingsContainerViewController: CSBCViewController {//, TimeEnteredDelegate {

    let schoolsNotifications = ["showSetonNotifications","showJohnNotifications","showSaintsNotifications","showJamesNotifications"]
    //var schoolSelectedOptional: String? = nil
    
    
    /*
    override func viewDidDisappear(_ animated: Bool) {
        var i = 0
        let notificationSettings = defineNotificationSettings()
        while schoolSelectedOptional == nil && i < 4 {
            if notificationSettings.schools[i] {
                schoolSelectedOptional = schoolsArray[i]
            }
            i += 1
        }
        if schoolSelectedOptional == nil {
            schoolSelectedOptional = "Seton"
        }
        print("attmpetimng to store school of \(schoolSelectedOptional!)")
    }
    */

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
