//
//  ContactTableViewDelegate.swift
//  CSBC
//
//  Created by Luke Redmore on 7/6/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import MessageUI


///Methods to display mail composer in Contacts view
class ContactMailDelegate: NSObject, MFMailComposeViewControllerDelegate {
    
    private let principalEmails = ["mmartinkovic","jfountaine","wpipher","skitchen"]
    
    var schoolSelected : Schools!
    private let parent : ContactViewController!

    init(parent: ContactViewController, schoolSelected: Schools) {
        self.parent = parent
        self.schoolSelected = schoolSelected
    }
    
    //MARK: Email Mehtods
    func presentMailVC() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            parent.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    private func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["\(principalEmails[schoolSelected.rawValue])@syrdiocese.org"])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("", isHTML: false)

        return mailComposerVC
    }
    private func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device cannot send email. Please check your email configuration and try again.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        sendMailErrorAlert.addAction(okButton)
        parent.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
