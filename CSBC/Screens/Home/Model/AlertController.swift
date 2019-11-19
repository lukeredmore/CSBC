//
//  AlertController.swift
//  CSBC
//
//  Created by Luke Redmore on 6/20/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import Firebase

protocol AlertDelegate: class {
    var alertMessage : String? { get set }
}

/// Checks for snow days and other critical alerts, tells the main screen and updates Firebase
class AlertController {
    weak private var alertDelegate : AlertDelegate!
    private var alertReturned = false
    
    init(alertDelegate : AlertDelegate) {
        self.alertDelegate = alertDelegate
    }
    
    func checkForAlert() {
        Database.database().reference().removeAllObservers()
        alertReturned = false
        Database.database().reference().child("BannerAlertMessage").observe(.value) { (snapshot) in
            if let alertMessage = snapshot.value as? String, alertMessage != "nil", alertMessage != "null" {
                self.alertDelegate.alertMessage = alertMessage
            } else {
                self.alertDelegate.alertMessage = nil
            }
            self.alertReturned = true
            return
        }
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            if !self.alertReturned {
                self.alertDelegate.alertMessage = nil
            }
        }
    }
}
