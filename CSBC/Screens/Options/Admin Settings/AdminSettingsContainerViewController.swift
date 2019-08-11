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
class AdminSettingsContainerViewController: CSBCViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    let allowedUserEmails = ["luke.redmore", "lukeredmore", "lredmore", "lredmore20", "mmartinkovic", "llevis", "skitchen", "isanyshyn", "kehret", "wpipher", "krosen", "jfountaine", "kpawlowski"]
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var testLabel: UILabel!
    
    var daySchedule = DaySchedule(forSeton: true, forJohn: true, forSaints: true, forJames: true)
    private var usersSchool = SchoolSelected(string: "Seton", int: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Admin"
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                signInButton.colorScheme = GIDSignInButtonColorScheme(rawValue: 0)!
            } else {
                signInButton.colorScheme = GIDSignInButtonColorScheme(rawValue: 1)!
            }
        }
        showAdminSettings(false)
        testLabel.text = "Please sign in to access this page."
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    override func viewDidDisappear(_ animated: Bool) {
        signOut()
    }
    
    
    //MARK: Sign In Methods
    func configureLogin(forUserID id : String) {
        usersSchool = determinePrioritiesForUser(userID: id)
        showAdminSettings(true)
    }
    func determinePrioritiesForUser(userID : String) -> SchoolSelected {
        switch userID {
        case "luke.redmore","lredmore","lredmore20","mmartinkovic","llevis":
            return SchoolSelected(string: "Seton", int: 0)
        case "krosen","jfountaine":
            return SchoolSelected(string: "St. John's", int: 1)
        case "wpipher","kpawlowski":
            return SchoolSelected(string: "All Saints", int: 2)
        case "skitchen","isanyshyn":
            return SchoolSelected(string: "St. James", int: 3)
        default:
            return SchoolSelected(string: "Seton", int: 4)
        }
    }
    func showAdminSettings(_ shouldBeSignedIn : Bool) {
        let childVC = children[0] as! AdminSettingsTableViewController
        if shouldBeSignedIn {
            signOutButton.titleLabel?.text = "Sign Out"
            childVC.usersSchool = usersSchool.ssString
            if let dayToSend = daySchedule.getDayOptional(forSchool: usersSchool.ssString, forDate: dateStringFormatter.string(from: Date())) {
                childVC.dayLabel.text = "\(dayToSend)"
                childVC.originalDay = dayToSend
            } else {
                childVC.dayLabel.text = ""
            }
        } else {
            signOutButton.titleLabel?.text = ""
            childVC.dayLabel.text = ""
            childVC.originalDay = nil
            childVC.usersSchool = nil
        }
        childVC.tableView.reloadData()
        containerView.isHidden = !shouldBeSignedIn
        signOutButton.isEnabled = shouldBeSignedIn
        signOutButton.isHidden = !shouldBeSignedIn
        signInButton.isEnabled = !shouldBeSignedIn
        signInButton.isHidden = shouldBeSignedIn
        testLabel.isHidden = shouldBeSignedIn
    }
    
    
    //MARK: Sign Out Methods
    @IBAction func signOutTapped(_ sender: Any) {
        signOut()
    }
    func signOut() {
        GIDSignIn.sharedInstance()?.disconnect()
        do {
            try Auth.auth().signOut()
            showAdminSettings(false)
        } catch let signOutError as NSError {
            print ("Error signing out: ", signOutError)
        }
    }
    
    
    //MARK: GIDSignIn Methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error signing into Google: ", error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential, completion: { (authResult, error) in
            if let error = error {
                print("Error signing into Firebase:", error)
                return
            } else {
                let userID : String = user.profile.email.components(separatedBy: "@")[0]
                if self.allowedUserEmails.contains(userID) {
                    print("user is authorized")
                    self.configureLogin(forUserID: userID)
                } else {
                    print("user unauthorized")
                    self.testLabel.text = "Only administrators may access these settings."
                    self.signOut()
                }
                
            }
        })
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user disconnected")
    }
}
