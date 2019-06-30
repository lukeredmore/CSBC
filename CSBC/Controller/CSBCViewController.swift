//
//  CSBCViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 6/29/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class CSBCViewController: UIViewController {
    
    var schoolSelected = SchoolSelected(string: "Seton", int: 0)
    var dateStringFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt
    }
    let threeLetterMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let schoolsArray = ["Seton","St. John's","All Saints","St. James"]
    let schoolsMap = ["Seton":0, "St. John's":1, "All Saints":2, "St. James":3]
    let userDefaults = UserDefaults.standard
    

    override func viewDidLoad() {
        super.viewDidLoad()
        schoolSelected = getSchoolSelected()
    }
    
    
    func shouldIShowAllSchools(schoolPicker : UISegmentedControl, schoolPickerHeightConstraint : NSLayoutConstraint) {
        if #available(iOS 13.0, *) {
            schoolPicker.overrideUserInterfaceStyle = .dark
        }
        let schoolNames = ["Seton","St. John's","All Saints","St. James"]
        let internalNotificationSettings = defineNotificationSettings()
        if let showAllSchools : Bool = UserDefaults.standard.value(forKey: "showAllSchools") as! Bool? {
            if showAllSchools {
                schoolPicker.removeAllSegments()
                for i in 0..<schoolNames.count {
                    schoolPicker.insertSegment(withTitle: schoolNames[i], at: i, animated: false)
                }
                schoolPickerHeightConstraint.constant = 45
                schoolPicker.isHidden = false
            } else {
                let schoolBools : [Bool] = internalNotificationSettings.schools
                //print(editedSchoolNames)
                schoolPicker.removeAllSegments()
                var indexAtWhichToInsertSegment = 0
                for i in 0..<schoolBools.count {
                    if schoolBools[i] {
                        schoolPicker.insertSegment(withTitle: schoolNames[i], at: indexAtWhichToInsertSegment, animated: false)
                        indexAtWhichToInsertSegment += 1
                        //print("thing inserted at \(i)")
                        //print("thing again inserted at \(indexAtWhichToInsertSegment)")
                    }
                }
                if schoolPicker.numberOfSegments == 1 {
                    schoolPickerHeightConstraint.constant = 0
                    schoolPicker.isHidden = true
                } else {
                    schoolPickerHeightConstraint.constant = 45
                    schoolPicker.isHidden = false
                }
                view.layoutIfNeeded()
            }
        } else {
            schoolPicker.removeAllSegments()
            for i in 0..<schoolNames.count {
                schoolPicker.insertSegment(withTitle: schoolNames[i], at: i, animated: false)
            }
            schoolPickerHeightConstraint.constant = 45
            schoolPicker.isHidden = false
        }
    }
    
    func getSchoolSelected() -> SchoolSelected {
        return SchoolSelected(string: userDefaults.string(forKey: "schoolSelected") ?? "Seton", int: schoolsMap[userDefaults.string(forKey: "schoolSelected") ?? "Seton"] ?? 0)
    }

}

extension UIViewController {
    func defineNotificationSettings() -> NotificationSettings {
        if let data = UserDefaults.standard.value(forKey:"Notifications") as? Data {
            let notificationSettings = try? PropertyListDecoder().decode(NotificationSettings.self, from: data)
            return notificationSettings!
        } else {
            let notificationSettings = NotificationSettings(shouldDeliver: true, deliveryTime: "7:00 AM", schools: [true, true, true, true], valuesChangedByUser: false)
            return notificationSettings
        }
    }
}

class CSBCPageViewController : UIPageViewController {
    var schoolSelected = SchoolSelected(string: "Seton", int: 0)
    var dateStringFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt
    }
    let threeLetterMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let schoolsArray = ["Seton","St. John's","All Saints","St. James"]
    let schoolsMap = ["Seton":0, "St. John's":1, "All Saints":2, "St. James":3]
    let userDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schoolSelected = getSchoolSelected()
    }
    
    func getSchoolSelected() -> SchoolSelected {
        return SchoolSelected(string: userDefaults.string(forKey: "schoolSelected") ?? "Seton", int: schoolsMap[userDefaults.string(forKey: "schoolSelected") ?? "Seton"] ?? 0)
    }
}

class SchoolSelected {
    var ssString : String = "Seton"
    var ssInt : Int = 0
    let schoolsMap = ["Seton":0, "St. John's":1, "All Saints":2, "St. James":3]
    let schoolsArray = ["Seton","St. John's","All Saints","St. James"]
    
    init(string : String, int : Int) {
        self.ssString = string
        self.ssInt = int
    }
    
    func update(_ schoolPicker : UISegmentedControl) {
        ssString = schoolPicker.titleForSegment(at: schoolPicker.selectedSegmentIndex) ?? "Seton"
        ssInt = schoolsMap[ssString] ?? 0
        UserDefaults.standard.set(schoolsArray[ssInt], forKey: "schoolSelected")
        print("schoolSelected stored as \(schoolsArray[ssInt])")
    }
}
