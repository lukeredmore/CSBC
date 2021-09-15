//
//  TodayContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol InputUpdateDelegate: AnyObject {
    func storeDateSelected(date : Date) //container tells pager that custom date was updated
    func schoolPickerValueDidChange() //container tells pager that schoolSelected changed
}
protocol PageViewDelegate: AnyObject {
    var dateToShow : Date { get set } //pager tells container the date shown as header
}

class TodayContainerViewController: CSBCViewController, PageViewDelegate {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var dateChangerButton: UIBarButtonItem! { didSet {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.addTarget(self, action: #selector(dateFilterSelected(_:)), for: .touchUpInside)
        button.setTitleColor(.csbcNavBarText, for: .normal)
        button.setTitle("•••", for: .normal)
        dateChangerButton.customView = button
        let multiTapGesture = UITapGestureRecognizer()
        multiTapGesture.numberOfTapsRequired = 2
        multiTapGesture.addTarget(self, action: #selector(dateChangerDoubleTapped))
        dateChangerButton.customView?.addGestureRecognizer(multiTapGesture)
    } }
    
    weak private var containerDelegate : InputUpdateDelegate!
    var dateToShow = Date() { didSet {
        title = Date().dateString() == dateToShow.dateString() ? "Today" : dateToShow.monthAbbreviationString() + " " + dateToShow.singleDayString()
    } }
    
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [containerView])
        super.viewWillAppear(animated)
    }
    
    override func schoolPickerValueChanged() {
        containerDelegate.schoolPickerValueDidChange()
    }
    
    @objc private func dateFilterSelected(_ sender: Any) {
        let vc = JumpToDateViewController(dateToShow: self.dateToShow, delegate: containerDelegate)
        present(vc, animated: true)
    }
    
    @objc private func dateChangerDoubleTapped() {
        if dateStringFormatter.string(from: dateToShow) != dateStringFormatter.string(from: Date()) {
            containerDelegate.storeDateSelected(date: Date())
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPageVC" {
            let childVC = segue.destination as! TodayPageViewController
            childVC.pagerDelegate = self
            containerDelegate = childVC
        }
    }
    

}
