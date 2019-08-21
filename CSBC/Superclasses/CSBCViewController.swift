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
    var schoolSelected : Schools {
        get {
            return Schools(rawValue: UserDefaults.standard.integer(forKey:"schoolSelected")) ?? .seton
        }
        set {
            let ssInt = newValue.rawValue
            UserDefaults.standard.set(ssInt, forKey:"schoolSelected")
            print("schoolSelected stored as \(newValue.ssString): \(ssInt)")
            schoolPickerValueChanged()
        }
    }
    var dateStringFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt
    }
    let threeLetterMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let schoolsArray = ["Seton","St. John's","All Saints","St. James"]
    let schoolsMap = ["Seton":0, "St. John's":1, "All Saints":2, "St. James":3]
    let userDefaults = UserDefaults.standard
    var schoolPicker = CSBCSegmentedControl()
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
        
    }
    
    func setupSchoolPickerAndBarForDefaultBehavior(topMostItems : [UIView], showAllSegments : Bool = false, barHeight : CGFloat = 8) {
        
        //Container Initialization and Layout
        let schoolPickerContainer = UIView()
        schoolPickerContainer.backgroundColor = .csbcNavBarBackground
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
            bar.heightAnchor.constraint(equalToConstant: barHeight),
            bar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        for item in topMostItems {
            view.addConstraint(item.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45 + barHeight))
        }
        
        //Picker Initialization
        let showAllSchools : Bool! = userDefaults.value(forKey: "showAllSchools") as? Bool ?? true
        if showAllSchools || showAllSegments {
            schoolPicker = CSBCSegmentedControl(items: ["Seton", "St. John's","All Saints","St. James"])
        } else {
            let notificationController = NotificationController()
            let schoolBools : [Bool] = notificationController.notificationSettings.schools
            schoolPicker = CSBCSegmentedControl()
            var indexAtWhichToInsertSegment = 0
            for i in schoolBools.indices {
                if schoolBools[i] {
                    schoolPicker.insertSegment(withTitle: schoolsArray[i], at: indexAtWhichToInsertSegment, animated: false)
                    indexAtWhichToInsertSegment += 1
                }
            }
        }
        schoolPicker.delegate = self
        
        
        //Picker Layout
        if schoolPicker.numberOfSegments != 1 {
            schoolPicker.translatesAutoresizingMaskIntoConstraints = false
            schoolPicker.tintColor = .white
            if #available(iOS 13.0, *) {
                schoolPicker.overrideUserInterfaceStyle = .dark
            }
            schoolPickerContainer.addSubview(schoolPicker)
            schoolPickerContainer.addConstraints([
                schoolPicker.topAnchor.constraint(equalTo: schoolPickerContainer.topAnchor, constant: 5),
                schoolPicker.heightAnchor.constraint(equalToConstant: 27),
                schoolPicker.leadingAnchor.constraint(equalTo: schoolPickerContainer.leadingAnchor, constant: 15),
                schoolPicker.trailingAnchor.constraint(equalTo: schoolPickerContainer.trailingAnchor, constant: -15)
            ])
            
            schoolPickerContainer.layoutSubviews()
            view.layoutIfNeeded()
        } else {
            view.addConstraints([
                schoolPickerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                schoolPickerContainer.heightAnchor.constraint(equalToConstant: 0),
                schoolPickerContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                schoolPickerContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
            for item in topMostItems {
                view.addConstraint(item.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0))
            }
            view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for i in 0..<schoolPicker.numberOfSegments {
            if schoolPicker.titleForSegment(at: i) == schoolSelected.ssString {
//                print("\(schoolSelected.ssString) was selected for segment \(i)")
                schoolPicker.setSelectedSegmentIndex(i)
                break
            } //else {
//                print("\(schoolSelected.ssString) was not selected for segment \(i)")
//            }
        }
    }
    
    func schoolPickerValueChanged() { }
}


protocol CSBCSegmentedControlDelegate : class {
    func schoolPickerValueChanged()
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
    
    @objc private func schoolPickerValueChanged(_ sender: CSBCSegmentedControl) {
        print("runs on programmatic change")
        let schoolsMap = ["Seton":0, "St. John's":1, "All Saints":2, "St. James":3]
        let ssString = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Seton"
        let ssInt = schoolsMap[ssString] ?? 0
        UserDefaults.standard.set(ssInt, forKey:"schoolSelected")
        print("schoolSelected stored as \(ssString): \(ssInt)")
        delegate?.schoolPickerValueChanged()
    }
}
