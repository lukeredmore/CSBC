//
//  AdminSettingsContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 5/13/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth


/// Container of admin settings. Contains admin authentication methods, hides/shows admin settings,
class AdminSettingsContainerViewController: CSBCViewController, GIDSignInDelegate {
    private let allowedUserEmails : [String:Schools] = [
        "lredmore": .seton, "lredmore20": .seton, "kehret": .seton, "ecarter": .seton, "mmartinkovic": .seton, "llevis": .seton,
        "jfountaine": .john, "krosen": .john,
        "wpipher": .saints, "kpawlowski": .saints,
        "skitchen": .james, "isanyshyn": .james]
    
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var signInButton: GIDSignInButton! {
        didSet {
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                signInButton.colorScheme = .dark
            } else {
                signInButton.colorScheme = .light
            }
            
            GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance()?.presentingViewController = self
        }
    }
    @IBOutlet weak private var signOutButton: UIButton!
    @IBOutlet weak private var messageLabel: UILabel!
    
    private var usersSchool : Schools? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Admin"
        
        showAdminSettings(false)
        messageLabel.text = "Please sign in to access this page."
    }
    override func viewDidDisappear(_ animated: Bool) {
        signOut()
    }
    
    
    //MARK: Sign In Methods
    ///GIDSignInDelegate Method
    func sign(_ signIn: GIDSignIn?, didSignInFor user: GIDGoogleUser?, withError error: Error?) {
        if let error = error {
            print("Error signing into Google: ", error)
            return
        } else if let userIDFull = user?.profile.email.components(separatedBy: "@") {
            if !allowedUserEmails.keys.contains(userIDFull[0]) || (!userIDFull[1].contains("syr") && !userIDFull[1].contains("seton")) {
                print("\(userIDFull[0]) is unauthorized")
                messageLabel.text = "Only administrators may access these settings."
                signOut()
                return
            } else if let userIDToken = user?.authentication?.idToken, let userAccessToken = user?.authentication?.accessToken {
                print("\(userIDFull[0]) is authorized")
                let credential = GoogleAuthProvider.credential(withIDToken: userIDToken, accessToken: userAccessToken)
                signIntoFirebase(with: credential, forUserID: userIDFull[0])
            }
        }
    }
    private func signIntoFirebase(with credential: AuthCredential, forUserID userID: String) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Error signing into Firebase: ", error)
                return
            } else {
                assert(self.allowedUserEmails.keys.contains(userID), "The user with id \(userID) is not allowed to acess these settings")
                self.configureLogin(forUserID: userID)
            }
        }
    }
    private func configureLogin(forUserID userID : String) {
        usersSchool = allowedUserEmails[userID]
        showAdminSettings(true)
    }
    private func showAdminSettings(_ shouldBeSignedIn : Bool) {
        guard let childVC = children[0] as? AdminSettingsTableViewController else { return }
        signOutButton.titleLabel?.text = shouldBeSignedIn ? "Sign Out" : ""
        childVC.usersSchool = shouldBeSignedIn ? usersSchool : nil
        childVC.tableView.reloadData()
        containerView.isHidden = !shouldBeSignedIn
        signOutButton.isEnabled = shouldBeSignedIn
        signOutButton.isHidden = !shouldBeSignedIn
        signInButton.isEnabled = !shouldBeSignedIn
        signInButton.isHidden = shouldBeSignedIn
        messageLabel.isHidden = shouldBeSignedIn
    }
    
    
    //MARK: Sign Out Methods
    @IBAction private func signOutTapped(_ sender: Any) {
        signOut()
    }
    private func signOut() {
        GIDSignIn.sharedInstance()?.disconnect()
        do {
            try Auth.auth().signOut()
            showAdminSettings(false)
        } catch let signOutError as NSError {
            print ("Error signing out: ", signOutError)
        }
    }
    ///GIDSignInDelegate Method
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user disconnected")
    }
}
