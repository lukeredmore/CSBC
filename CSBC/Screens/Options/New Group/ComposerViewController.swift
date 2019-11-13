//
//  ComposerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 5/22/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Alamofire

/// Configures composer view for user compose and prepares message to be sent
class ComposerViewController: UIViewController, UITextViewDelegate, PublishPushNotificationsDelegate {
    @IBOutlet weak private var textView: UITextView! { didSet {
        textView.delegate = self
    }}
    
    private var expectedPlaceholderColor : UIColor {
        if #available(iOS 13.0, *) {
            return .placeholderText
        } else {
            return .darkGray
        }
    }
    private var expectedTextColor : UIColor {
        return .csbcDefaultText
    }
    private var usersSchool : Schools? = nil
    private let notificationSample = "Enter a message"
    private let reportSample = "Please give a detailed description of the issue you would like to report or the suggestion you would like to submit:"
    
    
    static func instantiate(school : Schools? = nil) -> ComposerViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ComposerViewScene") as! ComposerViewController
        vc.usersSchool = school
        return vc
    }
    
    
    //MARK: View Control
    override func viewWillAppear(_ animated: Bool) {
        textView.text = usersSchool != nil ? notificationSample : reportSample
        textView.textColor = expectedPlaceholderColor
    }
    
    
    //MARK: Action Methods
    @IBAction private func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func sendButtonPressed(_ sender: Any) {
        performFinalAction()
    }
    private func performFinalAction() {
        if textView.text != "", textView.text != nil, textView.text != notificationSample, textView.text != reportSample {
            usersSchool != nil ? self.sendNotification() : self.sendReport()
        }
    }
    private func sendNotification() {
        if textView.text != "Enter a message" && usersSchool != nil {
            let notificationSender = PublishPushNotifications(withMessage: "\(textView.text!)", toSchool: usersSchool!)
            notificationSender.delegate = self
            notificationSender.sendNotification()
        }
    }
    private func sendReport() {
        print("sent")
    }
    
    
    //MARK: PublishPushNotificationDelegate Methods
    func notificationDidPublishSucessfully() {
        let alert = UIAlertController(title: "Notification sucessfully sent", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { action in self.dismiss(animated: true) }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    func notificationFailedToPublish(withError error: Error) {
        print("Error sending notification:", error)
        let alert = UIAlertController(title: "An error occurred", message: "The message could not be sent. Please check your connection and try again.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { action in self.dismiss(animated: true) }
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    
    //MARK: UITextViewDelegate Methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if ("\(textView.text!)" == notificationSample || "\(textView.text!)" == reportSample) && textView.textColor == expectedPlaceholderColor {
            textView.text = ""
            textView.textColor = expectedTextColor
        }
        textView.becomeFirstResponder()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = usersSchool != nil ? notificationSample : reportSample
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
}
