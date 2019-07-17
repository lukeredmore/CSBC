//
//  ComposerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 5/22/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Alamofire

/**
 Type of compose called in ComposerViewController
 
 - notification: Compose a push notification to publish
 - reportIssue: Compose a issue report to send to developer
*/
enum ComposeEventCalled {
    case notification, reportIssue
}

/// Configures composer view for user compose and prepares message to be sent
class ComposerViewController: UIViewController, UITextViewDelegate, PublishPushNotificationsDelegate {
    
    var expectedPlaceholderColor : UIColor {
        if #available(iOS 13.0, *) {
            return .placeholderText
        } else {
            return .darkGray
        }
    }
    var expectedTextColor : UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
    

    @IBOutlet weak var textView: UITextView!
    var usersSchool = ""
    var eventCalled : ComposeEventCalled = .reportIssue
    let notificationSample = "Enter a message"
    let reportSample = "Please give a detailed description of the issue you would like to report or the suggestion you would like to submit:"

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch eventCalled {
        case .notification: textView.text = notificationSample
        case .reportIssue: textView.text = reportSample
        }
        textView.textColor = expectedPlaceholderColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if ("\(textView.text!)" == notificationSample || "\(textView.text!)" == reportSample) && textView.textColor == expectedPlaceholderColor {
            textView.text = ""
            textView.textColor = expectedTextColor
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            switch eventCalled {
            case .notification: textView.text = notificationSample
            case .reportIssue: textView.text = reportSample
            }
            textView.textColor = expectedPlaceholderColor
        }
        textView.resignFirstResponder()
    }
    
//    func textViewShouldReturn(textView: UITextView!) -> Bool {
//        print("return key pressed")
//        textView.resignFirstResponder()
//        performFinalAction()
//        return false
//    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            performFinalAction()
            return false
        }
        return true
    }

    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        performFinalAction()
    }
    
    func performFinalAction() {
        if textView.text != "" && textView.text != nil {
            switch eventCalled {
            case .notification: self.sendNotification()
            case .reportIssue: self.sendReport()
            }
        }
    }
    
    
    func sendNotification() {
        if textView.text != "Enter a message" && usersSchool != "" {
            let notificationSender = PublishPushNotifications(withMessage: "\(textView.text!)", toSchool: usersSchool)
            notificationSender.delegate = self
            notificationSender.sendNotification()
        }
        
    }
    func sendReport() {
        print("sent")
    }
    
    
    //MARK: -Delegate methods
    func notificationDidPublishSucessfully() {
        let alert = UIAlertController(title: "Notification sucessfully sent", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    func notificationFailedToPublish(error: Error) {
        print("Error sending notification:", error)
        let alert = UIAlertController(title: "An error occurred", message: "The message could not be sent. Please check your connection and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }

}
