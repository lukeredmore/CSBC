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
        
    static let delegate = ContactMailDelegate()
    
    //MARK: Email Mehtods
    static func getMailVC(forSchool school: Schools) -> UIViewController {
        guard MFMailComposeViewController.canSendMail(), let mailComposeViewController = configuredMailComposeViewController(for: school) else {
            return sendEmailErrorAlert
        }
        return mailComposeViewController
    }
    private static func configuredMailComposeViewController(for school : Schools) -> MFMailComposeViewController? {
        guard let principalEmail = StaticData.readData(atPath: "\(school.singleStringLowercase)/info/email") else {return nil}
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = delegate
        mailComposerVC.setToRecipients([(principalEmail)])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("", isHTML: false)

        return mailComposerVC
    }
    static var sendEmailErrorAlert : UIAlertController {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device cannot send email. Please check your email configuration and try again.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        sendMailErrorAlert.addAction(okButton)
        return sendMailErrorAlert
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
