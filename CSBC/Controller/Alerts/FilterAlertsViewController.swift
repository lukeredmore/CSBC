//
//  FilterAlertsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/19/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol DateEnteredDelegate: class {
    func userDidSelectDate(dateToShow: Date)
}

final class FilterAlertsViewController: ModalMenuViewController {

    @IBOutlet var menuView: UIView!
    @IBOutlet var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var datePicker: UIDatePicker!
    
    //let menuView = UIView()
    weak var delegate: DateEnteredDelegate? = nil
    let daySchedule = DaySchedule()
    let formatter = DateFormatter()
    var startDate : Date?
    var endDate : Date?
    var dateToShow = Date()
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuView(menuView)
        //menuViewHeightConstraint.constant = UIScreen.main.bounds.height / 2 - 30
        formatter.dateFormat = "MM/dd/yyyy"
        let startDateString = daySchedule.startDateString
        startDate = formatter.date(from: startDateString)!
        let endDateString = daySchedule.endDateString
        endDate = formatter.date(from: endDateString)!
        datePicker.maximumDate = endDate
        datePicker.minimumDate = startDate
    }
    override func viewWillAppear(_ animated: Bool) {
        datePicker.setDate(dateToShow, animated: false)
    }
    override func passBackData() {
        //print(dateToShow)
        //print(datePicker.date)
        dateToShow = datePicker.date
        delegate?.userDidSelectDate(dateToShow: dateToShow)
    }
}

