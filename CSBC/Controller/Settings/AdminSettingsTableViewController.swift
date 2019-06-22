//
//  AdminSettingsTableViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 5/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase

class AdminSettingsTableViewController: UITableViewController {

    @IBOutlet weak var dayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegueFromContainer(identifier: "NotificationComposerSegue")
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegueFromContainer(identifier: "OverrideDayScheduleSegue")
        }
    }
    
    func performSegueFromContainer(identifier : String) {
        let masterVC = parent as! AdminSettingsContainerViewController
        masterVC.performSegue(withIdentifier: identifier, sender: masterVC)
    }
}
