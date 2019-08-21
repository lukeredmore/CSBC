//
//  TodayContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol DateEnteredDelegate: class { //modal menu tells container that custom date was selected
    func userDidSelectDate(dateToShow: Date)
}
protocol ContainerViewDelegate: class {
    func storeDateSelected(date : Date) //container tells pager that custom date was updated
    func schoolPickerValueDidChange() //container tells pager that schoolSelected changed
}
protocol PageViewDelegate: class {
    func scheduleDataDidDownload() //pager tells container that all async tasks completed
    func showDateAsHeader(dateGiven : Date) //pager tells container the date to show for header
    var dateToShow : Date { get } //the date shown
}
protocol TodayParserDelegate: JSParsingDelegate { //parser tells pager to initialize VCs
    func startupPager()
    var schoolSelected : Schools { get }
}

class TodayContainerViewController: CSBCViewController, DateEnteredDelegate, PageViewDelegate {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var dateChangerButton: UIBarButtonItem!
    
    weak private var containerDelegate : ContainerViewDelegate? = nil
    var dateToShow = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Today"
        loadingSymbol.startAnimating()
        setupTapGestureForSettingsButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [containerView])
        super.viewWillAppear(animated)
    }
    
    override func schoolPickerValueChanged() {
        containerDelegate?.schoolPickerValueDidChange()
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
    
    private func setupTapGestureForSettingsButton() {
        let multiTapGesture = UITapGestureRecognizer()
        multiTapGesture.numberOfTapsRequired = 2
        multiTapGesture.addTarget(self, action: #selector(dateChangerDoubleTapped))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.addTarget(self, action: #selector(dateFilterSelected(_:)), for: .touchUpInside)
        button.setTitleColor(.csbcNavBarText, for: .normal)
        button.setTitle("•••", for: .normal)
        dateChangerButton.customView = button
        dateChangerButton.customView?.addGestureRecognizer(multiTapGesture)
    }
    
    @objc private func dateFilterSelected(_ sender: Any) {
        if loadingSymbol.isHidden {
            performSegue(withIdentifier: "AlertsSettingsSegue", sender: self)
        }
    }
    
    @objc private func dateChangerDoubleTapped() {
        if dateStringFormatter.string(from: dateToShow) != dateStringFormatter.string(from: Date()) && loadingSymbol.isHidden {
            userDidSelectDate(dateToShow: Date())
        }
    }
    
    func userDidSelectDate(dateToShow: Date) {
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
        containerDelegate?.storeDateSelected(date: dateToShow)
    }
    
    func scheduleDataDidDownload() {
        loadingSymbol.stopAnimating()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPageVC" {
            let childVC = segue.destination as! PageViewController
            childVC.pagerDelegate = self
            containerDelegate = childVC
        } else if segue.identifier == "AlertsSettingsSegue" {
            let childVC = segue.destination as! FilterAlertsViewController
            childVC.delegate = self
            childVC.dateToShow = self.dateToShow
        }
    }
    

}
