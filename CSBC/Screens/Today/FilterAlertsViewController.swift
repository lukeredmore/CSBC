//
//  FilterAlertsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/19/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

final class FilterAlertsViewController: ModalMenuViewController {
    @IBOutlet private var menuView: UIView!
    @IBOutlet private var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var datePicker: UIDatePicker!
    
    weak var delegate: DateEnteredDelegate? = nil
    private let daySchedule = DaySchedule()
    private let formatter = DateFormatter()
    private var startDate : Date?
    private var endDate : Date?
    var dateToShow = Date()
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuView(menuView)
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
        dateToShow = datePicker.date
        delegate?.userDidSelectDate(dateToShow: dateToShow)
    }
}

