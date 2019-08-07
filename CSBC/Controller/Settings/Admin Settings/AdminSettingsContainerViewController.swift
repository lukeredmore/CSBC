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
class AdminSettingsContainerViewController: CSBCViewController, GIDSignInDelegate, GIDSignInUIDelegate, DayOverriddenDelegate {

    
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
        viewSwitch(shouldBeSignedIn: false)
        testLabel.text = "Please sign in to access this page."
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    @IBAction func signOutTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.disconnect()
        signOut()
    }
    
    
    //MARK: UI Methods
    func viewSwitch(shouldBeSignedIn : Bool) {
        containerView.isHidden = !shouldBeSignedIn
        signOutButton.isEnabled = shouldBeSignedIn
        signOutButton.isHidden = !shouldBeSignedIn
        if shouldBeSignedIn {
            signOutButton.titleLabel?.text = "Sign Out"
            let childVC = children[0] as! AdminSettingsTableViewController
            childVC.dayLabel.text = "\(daySchedule.getDay(forSchool: usersSchool, forDate: Date()))"
        } else {
            signOutButton.titleLabel?.text = "."
        }
        signInButton.isEnabled = !shouldBeSignedIn
        signInButton.isHidden = shouldBeSignedIn
        testLabel.isHidden = shouldBeSignedIn
    }
    
    
    //MARK: Admin Actions
    func adminDidOverrideDay(day: Int) {
        if let childVC = children[0] as? AdminSettingsTableViewController {
            if let originalDay = daySchedule.getDayOptional(forSchool: usersSchool.ssString, forDate: dateStringFormatter.string(from: Date())) {
                var dictToStore = UserDefaults.standard.dictionary(forKey: "dayScheduleOverrides") as? [String:Int] ?? ["Seton":0,"John":0,"Saints":0,"James":0]
                dictToStore[usersSchool.ssString] = day - originalDay + dictToStore[usersSchool.ssString]!
                
                let messagesDB = Database.database().reference().child("DayScheduleOverrides")
                print("Adding day schedule override to database")
                messagesDB.updateChildValues(dictToStore) {
                    (error, reference) in
                    if error != nil {
                        print("Error adding day schedule override to databae:", error!)
                    } else {
                        UserDefaults.standard.set(dictToStore, forKey: "dayScheduleOverrides")
                        print("Override added")
                        self.daySchedule = DaySchedule(forSeton: true, forJohn: true, forSaints: true, forJames: true)
                        childVC.dayLabel.text = "\(day)"
                    }
                }
            }
        }
    }
    
    
    //MARK: Authentication Methods
    //Delegate methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error signing into Google:", error)
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
                    self.usersSchool = self.determinePrioritiesForUser(userID: userID)
                    
                    self.viewSwitch(shouldBeSignedIn: true)
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
    
    //Newly created
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            viewSwitch(shouldBeSignedIn: false)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
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
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NotificationComposerSegue" {
            let childVC = segue.destination as! ComposerViewController
            childVC.usersSchool = usersSchool.ssString
            childVC.eventCalled = .notification
        }
        if segue.identifier == "OverrideDayScheduleSegue" {
            let childVC = segue.destination as! SetDeliveryTimeViewController
            childVC.dayOverrideDelegate = self
            //print(daySchedule.dateDayDict[usersSchool]![fmt.string(from: Date())] ?? 0)
            childVC.dayToShow = daySchedule.getDay(forSchool: usersSchool, forDate: Date())
        }
    }
    
}
