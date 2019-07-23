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
    
    let schoolPhone : [[String]] = [["723.5307", "723.4811"],["723.0703","772.6210"],["748.7423"],["797.5444"]]
    let districtPhone = "723.1547"
    let principalEmails = ["mmartinkovic","jfountaine","atierno","skitchen"]
    
    var schoolSelected : SchoolSelected!
    let parent : ContactViewController!

    init(parent: ContactViewController, schoolSelected: SchoolSelected) {
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
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(["\(principalEmails[schoolSelected!.ssInt])@syrdiocese.org"])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("", isHTML: false)

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
