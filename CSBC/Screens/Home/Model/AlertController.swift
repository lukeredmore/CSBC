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
    private var triedToRunFirstTimeInVWA = false
    
    init(alertDelegate : AlertDelegate) {
        self.alertDelegate = alertDelegate
    }
    
    func checkForAlert() {
        if triedToRunFirstTimeInVWA {
            Database.database().reference().removeAllObservers()
            Database.database().reference().child("BannerAlertMessage").observe(.value) { (snapshot) in
                if let alertMessage = snapshot.value as? String, alertMessage != "nil", alertMessage != "null" {
                    self.alertDelegate.alertMessage = alertMessage
                } else {
                    self.alertDelegate.alertMessage = nil
                }
            }
        }
        else {
            triedToRunFirstTimeInVWA = true
            Timer.scheduledTimer(withTimeInterval: 1.4, repeats: false) { (timer) in
                self.checkForAlert()
            }
        }
        
    }
}
