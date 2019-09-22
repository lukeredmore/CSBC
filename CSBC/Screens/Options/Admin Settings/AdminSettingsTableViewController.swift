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
class AdminSettingsTableViewController: UITableViewController {

//    private let notificationController = NotificationController()
    var usersSchool : Schools? = nil
//    var originalDay : Int? = nil
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0, usersSchool != nil {
            let notificationSenderVC = ComposerViewController.instantiate(school: usersSchool)
            self.present(notificationSenderVC, animated: true, completion: nil)
        }
    }
    
}
