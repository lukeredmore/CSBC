//
//  AthleticsTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 2/21/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import EventKitUI

///Contains properties for cells in Athetlics View, and can add data to them given and AthleticsModel and index
class AthleticsTableViewCell: UITableViewCell, DisplayInSearchableTableView {
    
    let eventStore = EKEventStore()
    var data : AthleticsModel?

    //MARK: Properties
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var levelLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!
    
    func addData<T>(_ genericModel: T) where T : Searchable {
        guard let model = genericModel as? AthleticsModel else { return }
        self.data = model
        let charactersToFilter = CharacterSet(charactersIn: ":()1234567890")
        let titleText = model.title.components(separatedBy: charactersToFilter).joined()
        titleLabel.text = titleText
        levelLabel.text = model.level
        timeLabel.text = model.time
        selectionStyle = .none
    }
    
    override func customMenuItemTapped(_ sender: UIMenuController) {

        checkCalendarAuthorizationStatus()
        
//        let eventVC = EKEventEditViewController()
//        eventVC.
//        eventViewController.event = sourceArray[indexPath.row]
//        eventViewController.eventStore = self.eventStore
//        eventViewController.editViewDelegate = self
        
    }
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
    
        switch (status) {
            case EKAuthorizationStatus.notDetermined:
                // This happens on first-run
                requestAccessToCalendar()
            case EKAuthorizationStatus.authorized:
                // Things are in line with being able to show the calendars in the table view
                loadCalendars()
            case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
               // We need to help them give us permission
                badPermissions()
            
        }
    }
    
    func requestAccessToCalendar() {
             eventStore.requestAccess(to: EKEntityType.event, completion: {
                (accessGranted: Bool, error: Error?) in
                
                 if accessGranted == true {
                    DispatchQueue.main.async(execute: {
                        self.loadCalendars()
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.badPermissions()
                    })
                }
            })
        }
    
    func loadCalendars() {
        let eventVC = EKEventEditViewController()
        self.window?.rootViewController?.present(eventVC, animated: true)
    }
    func badPermissions() {
        let alert = UIAlertController(title: "Cannot access your Calendar", message: "Please enable in Settings", preferredStyle: .alert)
        self.window?.rootViewController?.present(alert, animated: true)
    }

}
