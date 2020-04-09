//
//  SettingsContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/4/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

///Authenticates teachers and administrators through GIDSignIn in order to show hidden settings
class SettingsContainerViewController: UIViewController {
    private let defaults = UserDefaults.standard
    
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let user = user else { self.cleanUpAfterSignOut(); return }
            Database.database().reference(withPath: "Users").observeSingleEvent(of: .value) { snapshot in
                let allUsers = Array((snapshot.value as! [String:[String:Any]]).values)
                guard let userInSystem = allUsers.first(where: { userObject -> Bool in
                    guard let email = userObject["email"] as? String else { return false }
                    return email == user.email
                }) else { self.handleUnauthorizedUser(); return }
                let passAccess = userInSystem["passAccess"] as? Bool ?? false
                let notificationSchool = Int(userInSystem["notificationSchool"] as? String ?? "")
                let notifyOutstanding = userInSystem["notifyOutstanding"] as? Bool ?? false
                    
                if notifyOutstanding || passAccess || notificationSchool != nil {
                    self.addSignedInUserToPreferences(passAccess: passAccess, notificationSchool: notificationSchool, notifyOutstanding: notifyOutstanding)
                } else { self.handleUnauthorizedUser() }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBOutlet weak private var loginButton: UIButton! { didSet {
        let loginButtonTitle = Auth.auth().currentUser == nil ? "Sign In" : "Sign Out"
        loginButton.setTitle(loginButtonTitle, for: .normal)
        GIDSignIn.sharedInstance()?.presentingViewController = self
    } }
    private var tableVC : SettingsViewController!
    
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if sender.currentTitle == "Sign Out" {
            startSignOut()
            alert("Sucessfully signed out.")
        } else if sender.currentTitle == "Sign In" {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    
    //MARK: Sign In Methods
    private func handleUnauthorizedUser() {
        alert("You must be an approved teacher or administrator to access these settings.")
        startSignOut()
    }
    private func addSignedInUserToPreferences(passAccess: Bool?, notificationSchool: Int?, notifyOutstanding: Bool?) {
        loginButton.setTitle("Sign Out", for: .normal)
        defaults.set(notificationSchool, forKey: "notificationSchool")
        defaults.set(passAccess, forKey: "passAccess")
        defaults.set(notifyOutstanding, forKey: "notifyOutstanding")
        if notifyOutstanding ?? false {
            Messaging.messaging().subscribe(toTopic: "notifyOutstanding") { error in
                if error != nil { print("Error subscribing to notifyOutstanding: \(error!)") }
                else { print("Subscribed to notifyOutstanding") }
            }
        }
        tableVC.refreshTable()
    }
    
    //MARK: Sign Out Methods
    private func startSignOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    private func cleanUpAfterSignOut() {
        guard loginButton.currentTitle == "Sign Out" else { return }
        GIDSignIn.sharedInstance()?.disconnect()
        loginButton.setTitle("Sign In", for: .normal)
        defaults.set(nil, forKey: "notificationSchool")
        defaults.set(nil, forKey: "passAccess")
        defaults.set(nil, forKey: "notifyOutstanding")
        tableVC.refreshTable()
        Messaging.messaging().unsubscribe(fromTopic: "notifyOutstanding") { error in
            if let error = error { print("Error unsubscribing from notifyOutstanding: \(error)") }
            else { print("Unsubscribed from notifyOutstanding") }
        }
    }
    
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsTableEmbed" {
            tableVC = segue.destination as? SettingsViewController
        }
    }
    
}
