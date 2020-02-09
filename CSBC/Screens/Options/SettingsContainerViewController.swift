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
    private let allowedUserEmails : [String:Schools] = [
    "lredmore": .seton, "kehret": .seton, "ecarter": .seton, "mmartinkovic": .seton, "llevis": .seton,
    "jfountaine": .john, "krosen": .john,
    "wpipher": .saints, "kpawlowski": .saints,
    "skitchen": .james, "isanyshyn": .james]
    
    @IBOutlet weak private var loginButton: UIButton! { didSet {
        if defaults.bool(forKey: "userIsATeacher") || defaults.bool(forKey: "userIsAnAdmin") {
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
            let alert = UIAlertController(title: nil, message: "Sucessfully signed out.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            signOut()
        } else if sender.currentTitle == "Sign In" {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    
    //MARK: Sign In Methods
    ///GIDSignInDelegate Method
    func sign(_ signIn: GIDSignIn?, didSignInFor user: GIDGoogleUser?, withError error: Error?) {
        if error != nil { print("Error signing into Google: ", error!); return }
        guard let userEmailComponents = user?.profile.email.components(separatedBy: "@") else { return }
        
        if userEmailComponents[0] == "lredmore" {
            Messaging.messaging().subscribe(toTopic: "debugDevice") { error in
                if let error = error { print("Error subscribing to topics: \(error)") }
                else { print("Subscribed to debugDevice") }
            }
        }
        if allowedUserEmails.keys.contains(userEmailComponents[0]) && userEmailComponents[1].contains("syrdio") && userEmailComponents[0].rangeOfCharacter(from: .decimalDigits) == nil { //prefix has no numbers, user is in explicit admins, and email ends in syrdio
            print("setting button title to sign out")
            loginButton.setTitle("Sign Out", for: .normal)
            defaults.set(true, forKey: "userIsAnAdmin")
            defaults.set(allowedUserEmails[userEmailComponents[0]]!.rawValue, forKey: "adminSchool")
        } else if userEmailComponents[1].contains("syrdio") && userEmailComponents[0].rangeOfCharacter(from: .decimalDigits) == nil { //prefix has no numbers, and email ends in syrdio
            loginButton.setTitle("Sign Out", for: .normal)
            defaults.set(true, forKey: "userIsATeacher")
        } else {
            print("\(userEmailComponents[0]) is unauthorized")
            let alert = UIAlertController(title: nil, message: "You must be a teacher or administrator to access these settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            signOut()
        }
        tableVC.refreshTable()
    }
    
    //MARK: Sign Out Methods
    func signOut() {
        GIDSignIn.sharedInstance()?.disconnect()
        loginButton.setTitle("Sign In", for: .normal)
        defaults.set(false, forKey: "userIsATeacher")
        defaults.set(false, forKey: "userIsAnAdmin")
        tableVC.refreshTable()
        Messaging.messaging().unsubscribe(fromTopic: "debugDevice") { error in
            if let error = error { print("Error unsubscribing from topics: \(error)") }
            else { print("Unsubscribed from debugDevice") }
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
