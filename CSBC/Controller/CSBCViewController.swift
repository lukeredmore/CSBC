//
//  CSBCViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 6/29/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

/// Default superclass for View Controllers in CSBC with access to common methods (setting up segmented control and finding the selected school)
class CSBCViewController: UIViewController, CSBCSegmentedControlDelegate {
    
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
    var schoolPicker : CSBCSegmentedControl? = nil
    let loadingSymbol : UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingSymbol.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingSymbol.style = .large
        } else {
            loadingSymbol.style = .whiteLarge
            loadingSymbol.color = .gray
        }
        loadingSymbol.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingSymbol)
        view.addConstraints([
            loadingSymbol.heightAnchor.constraint(equalToConstant: 50),
            loadingSymbol.widthAnchor.constraint(equalToConstant: 50),
            loadingSymbol.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSymbol.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30)
        ])
        
        schoolSelected = getSchoolSelected()
    }
    
    func setupSchoolPickerAndBarForDefaultBehavior(topMostItems : [UIView], showAllSegments : Bool = false) {
        
        //Container Initialization and Layout
        let schoolPickerContainer = UIView()
        schoolPickerContainer.backgroundColor = UIColor(named: "CSBCNavBarBackground")
        schoolPickerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(schoolPickerContainer)
        view.addConstraints([
            schoolPickerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            schoolPickerContainer.heightAnchor.constraint(equalToConstant: 45),
            schoolPickerContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            schoolPickerContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        let bar = UIView()
        bar.backgroundColor = .csbcYellow
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        view.addConstraints([
            bar.topAnchor.constraint(equalTo: schoolPickerContainer.bottomAnchor),
            bar.heightAnchor.constraint(equalToConstant: 8),
            bar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        for item in topMostItems {
            view.addConstraint(item.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 53))
        }
        
        view.layoutIfNeeded()
        
        //Picker Initialization
        let showAllSchools : Bool! = userDefaults.value(forKey: "showAllSchools") as? Bool ?? true
        if showAllSchools || showAllSegments {
            schoolPicker = CSBCSegmentedControl(items: ["Seton", "St. John's","All Saints","St. James"])
        } else {
            let notificationController = NotificationController()
            let schoolBools : [Bool] = notificationController.notificationSettings.schools
            schoolPicker = CSBCSegmentedControl()
            var indexAtWhichToInsertSegment = 0
            for i in 0..<schoolBools.count {
                if schoolBools[i] {
                    schoolPicker?.insertSegment(withTitle: schoolsArray[i], at: indexAtWhichToInsertSegment, animated: false)
                    indexAtWhichToInsertSegment += 1
                }
            }
        }
        schoolPicker!.delegate = self
        
        
        //Picker Layout
        if schoolPicker!.numberOfSegments != 1 {
            schoolPicker!.translatesAutoresizingMaskIntoConstraints = false
            schoolPicker!.tintColor = .white
            if #available(iOS 13.0, *) {
                schoolPicker!.overrideUserInterfaceStyle = .dark
            }
            schoolPickerContainer.addSubview(schoolPicker!)
            schoolPickerContainer.addConstraints([
                schoolPicker!.topAnchor.constraint(equalTo: schoolPickerContainer.topAnchor, constant: 5),
                schoolPicker!.heightAnchor.constraint(equalToConstant: 27),
                schoolPicker!.leadingAnchor.constraint(equalTo: schoolPickerContainer.leadingAnchor, constant: 15),
                schoolPicker!.trailingAnchor.constraint(equalTo: schoolPickerContainer.trailingAnchor, constant: -15)
            ])
            
            schoolPickerContainer.layoutSubviews()
            view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if schoolPicker != nil {
            for i in 0..<schoolPicker!.numberOfSegments {
                if schoolPicker!.titleForSegment(at: i) == schoolSelected.ssString {
                    print("\(schoolSelected.ssString) was selected for segment \(i)")
                    schoolPicker!.setSelectedSegmentIndex(i)
                    break
                } else {
                    print("\(schoolSelected.ssString) was not selected for segment \(i)")
                }
            }
        }
    }
    
    /*
     func shouldIShowAllSchools(schoolPicker : UISegmentedControl, schoolPickerHeightConstraint : NSLayoutConstraint) {
     if #available(iOS 13.0, *) {
     schoolPicker.overrideUserInterfaceStyle = .dark
     }
     
     if let showAllSchools : Bool = UserDefaults.standard.value(forKey: "showAllSchools") as! Bool? {
     if showAllSchools {
     schoolPicker.removeAllSegments()
     for i in 0..<schoolsArray.count {
     schoolPicker.insertSegment(withTitle: schoolsArray[i], at: i, animated: false)
     }
     schoolPickerHeightConstraint.constant = 45
     schoolPicker.isHidden = false
     } else {
     let schoolBools : [Bool] = notificationController.notificationSettings.schools
     //print(editedSchoolNames)
     schoolPicker.removeAllSegments()
     var indexAtWhichToInsertSegment = 0
     for i in 0..<schoolBools.count {
     if schoolBools[i] {
     schoolPicker.insertSegment(withTitle: schoolsArray[i], at: indexAtWhichToInsertSegment, animated: false)
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
     for i in 0..<schoolsArray.count {
     schoolPicker.insertSegment(withTitle: schoolsArray[i], at: i, animated: false)
     }
     schoolPickerHeightConstraint.constant = 45
     schoolPicker.isHidden = false
     }
     
     }
     */
    
    
    
    func schoolPickerValueChanged(_ sender : CSBCSegmentedControl) {
        schoolSelected.update(sender)
    }
    
    func getSchoolSelected() -> SchoolSelected {
        return SchoolSelected(string: userDefaults.string(forKey: "schoolSelected") ?? "Seton", int: schoolsMap[userDefaults.string(forKey: "schoolSelected") ?? "Seton"] ?? 0)
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

protocol CSBCSegmentedControlDelegate : class {
    func schoolPickerValueChanged(_ sender : CSBCSegmentedControl)
}
class CSBCSegmentedControl : UISegmentedControl {
    
    weak var delegate : CSBCSegmentedControlDelegate? = nil
    
    override init(items: [Any]?) {
        super.init(items: items)
        addTarget(self, action: #selector(schoolPickerValueChanged), for: .valueChanged)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(schoolPickerValueChanged), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelectedSegmentIndex(_ index: Int) {
        selectedSegmentIndex = index
        schoolPickerValueChanged(self)
    }
    
    @objc func schoolPickerValueChanged(_ sender: CSBCSegmentedControl) {
        print("runs on programmatic change")
        print(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
        delegate?.schoolPickerValueChanged(sender)
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
