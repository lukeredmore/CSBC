//
//  TodayContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol PageViewLoadedDelegate: class {
    func pageViewDidLoad()
}
protocol PageViewSchoolPickerDelegate: class {
    func schoolPickerValueDidChange()
}

class TodayContainerViewController: CSBCViewController, TellDateShownToParentVC, DateEnteredDelegate, PageViewLoadedDelegate {
    
    var athleticsData = AthleticsDataParser()
    var calendarData = EventsParsing()
    weak var pageViewSchoolPickerDelegate : PageViewSchoolPickerDelegate? = nil
    weak var dateForPageDelegate : DateForPageDelegate? = nil
    //let schoolNames = ["Seton","St. John's","All Saints","St. James"]
    //let schoolBoolStrings = ["showSetonNotifications","showJohnNotifications","showSaintsNotifications","showJamesNotifications"]
    var dateToShow = Date()
    
    
    @IBOutlet weak var schoolPicker: UISegmentedControl!
    @IBOutlet weak var schoolPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateChangerButton: UIBarButtonItem!
    @IBOutlet weak var loadingSymbol: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Today"
        loadingSymbol.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingSymbol.style = .large
        } else {
            loadingSymbol.style = .whiteLarge
            loadingSymbol.color = .gray
        }
        setupTapGestureForSettingsButton()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadingSymbol.startAnimating()
        shouldIShowAllSchools(schoolPicker: schoolPicker, schoolPickerHeightConstraint: schoolPickerHeightConstraint)
        for i in 0..<schoolPicker.numberOfSegments {
            if schoolPicker.titleForSegment(at: i) == schoolSelected.ssString {
                schoolPicker.selectedSegmentIndex = i
                //print("\(i) was selected")
            } //else { print("\(i) wasn't selected") }
        }
        
    }
    
    @IBAction func schoolPickerValueChanged(_ sender: Any) {
        loadingSymbol.startAnimating()
        schoolSelected.update(schoolPicker)
        pageViewSchoolPickerDelegate?.schoolPickerValueDidChange()
        loadingSymbol.stopAnimating()
    }
    
    func showDateAsHeader(dateGiven : Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        dateToShow = dateGiven
        if formatter.string(from: Date()) == formatter.string(from: dateGiven) {
            self.title = "Today"
        } else {
            self.title = formatter.string(from: dateGiven)
        }
        
    }
    
    func setupTapGestureForSettingsButton() {
        let multiTapGesture = UITapGestureRecognizer()
        multiTapGesture.numberOfTapsRequired = 2
        multiTapGesture.addTarget(self, action: #selector(dateChangerDoubleTapped))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.addTarget(self, action: #selector(dateFilterSelected(_:)), for: .touchUpInside)
        button.setTitleColor(UIColor(named: "CSBCNavBarText"), for: .normal)
        button.setTitle("•••", for: .normal)
        dateChangerButton.customView = button
        dateChangerButton.customView?.addGestureRecognizer(multiTapGesture)
    }
    
    @objc func dateFilterSelected(_ sender: Any) {
        if loadingSymbol.isHidden {
            performSegue(withIdentifier: "AlertsSettingsSegue", sender: self)
        }
    }
    
    @objc func dateChangerDoubleTapped() {
        if dateStringFormatter.string(from: dateToShow) != dateStringFormatter.string(from: Date()) && loadingSymbol.isHidden {
            userDidSelectDate(dateToShow: Date())
        }
    }
    
    func userDidSelectDate(dateToShow: Date) {
        loadingSymbol.startAnimating()
        self.dateToShow = dateToShow
        let dateString = dateStringFormatter.string(from: dateToShow)
        let todaysRealDateString = dateStringFormatter.string(from: Date())
        if dateString != todaysRealDateString {
            let titleFormat = DateFormatter()
            titleFormat.dateFormat = "MMM d"
            let dateToTitleString = titleFormat.string(from: dateToShow)
            self.title = dateToTitleString
        } else {
            self.title = "Today"
        }
        dateForPageDelegate?.storeDateSelected(date: dateToShow)
    }
    
    func pageViewDidLoad() {
        loadingSymbol.stopAnimating()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPageVC" {
            let childVC = segue.destination as! PageViewController
            childVC.dateDelegate = self
            childVC.athleticsData = self.athleticsData
            childVC.calendarData = self.calendarData
            print(self.schoolSelected,"in prepare for degueas")
            dateForPageDelegate = childVC
            pageViewSchoolPickerDelegate = childVC
        } else if segue.identifier == "AlertsSettingsSegue" {
            let childVC = segue.destination as! FilterAlertsViewController
            childVC.delegate = self
            childVC.dateToShow = self.dateToShow
        }
    }
    

}
