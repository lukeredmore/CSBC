//
//  SettingsViewDataSource.swift
//  CSBC
//
//  Created by Luke Redmore on 7/17/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import MessageUI


///Mail delegate methods for SettingsTableViewController
class SettingsViewDelegate: NSObject, MFMailComposeViewControllerDelegate {
    
    let parent : SettingsViewController!
    
    init(_ parent: SettingsViewController) {
        self.parent = parent
    }
    
    //MARK: Mail Delegate
    func presentMailVC() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            parent.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["lredmore@syrdio.org"])
        mailComposerVC.setSubject("CSBC App User Comment")
        mailComposerVC.setMessageBody("Please give a detailed description of the issue you would like to report or the suggestion you would like to submit:", isHTML: false)
        
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send email. Please check your email configuration and try again.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        sendMailErrorAlert.addAction(okButton)
        parent.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
