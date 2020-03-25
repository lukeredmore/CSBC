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
class SettingsContainerViewController: UIViewController, GIDSignInDelegate {
    private let defaults = UserDefaults.standard
    
    @IBOutlet weak private var loginButton: UIButton! { didSet {
        if defaults.bool(forKey: "passAccess") || defaults.bool(forKey: "notifyOutstanding") || defaults.value(forKey: "notificationSchool") as? String != nil {
            loginButton.setTitle("Sign Out", for: .normal)
        } else {
            loginButton.setTitle("Sign In", for: .normal)
        }
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    } }
    private var tableVC : SettingsViewController!
    
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if sender.currentTitle == "Sign Out" {
            alert("Sucessfully signed out.")
            signOut()
        } else if sender.currentTitle == "Sign In" {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    
    //MARK: Sign In Methods
    ///GIDSignInDelegate Method
    func sign(_ signIn: GIDSignIn?, didSignInFor user: GIDGoogleUser?, withError error: Error?) {
        if error != nil { print("Error signing into Google: ", error!); return }
        
        Database.database().reference(withPath: "Users").observeSingleEvent(of: .value) { snapshot in
            let allUsers = Array((snapshot.value as! [String:[String:Any]]).values)
            let userWithEmail = allUsers.first { userObject -> Bool in
                guard let email = userObject["email"] as? String else { return false }
                return email == user?.profile.email
            }
            if let userInSystem = userWithEmail {
                let passAccess = userInSystem["passAccess"] as? Bool
                let notificationSchool = Int(userInSystem["notificationSchool"] as? String ?? "")
                let notifyOutstanding = userInSystem["notifyOutstanding"] as? Bool
                
                if notifyOutstanding ?? false || passAccess ?? false || notificationSchool != nil {
                    self.addSignedInUserToPreferences(passAccess: passAccess, notificationSchool: notificationSchool, notifyOutstanding: notifyOutstanding)
                    return
                }
            }
            self.handleUnauthorizedUser()
            
        }
    }
    private func handleUnauthorizedUser() {
        alert("You must be an approved teacher or administrator to access these settings.")
        signOut()
        tableVC.refreshTable()
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
    func signOut() {
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
    ///GIDSignInDelegate Method
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error { print("Error signing out: ", error) }
        else { print("Google user disconnected") }
    }
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsTableEmbed" {
            tableVC = segue.destination as? SettingsViewController
        }
    }
    
}
