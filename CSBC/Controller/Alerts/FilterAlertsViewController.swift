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

final class FilterAlertsViewController: UIViewController {
    
    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    @IBOutlet var menuView: UIView!
    @IBOutlet var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var datePicker: UIDatePicker!
    
    
    //let menuView = UIView()
    let menuHeight = UIScreen.main.bounds.height / 2
    var isPresenting = false
    weak var delegate: DateEnteredDelegate? = nil
    let daySchedule = DaySchedule()
    let formatter = DateFormatter()
    var startDate : Date?
    var endDate : Date?
    var dateToShow = Date()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //menuViewHeightConstraint.constant = UIScreen.main.bounds.height / 2 - 30
        menuView.layer.cornerRadius = 5
        menuView.layer.masksToBounds = true
        formatter.dateFormat = "MM/dd/yyyy"
        let startDateString = daySchedule.startDateString
        startDate = formatter.date(from: startDateString)!
        let endDateString = daySchedule.endDateString
        endDate = formatter.date(from: endDateString)!
        datePicker.maximumDate = endDate
        datePicker.minimumDate = startDate
        
        
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        view.addSubview(menuView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FilterAlertsViewController.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        datePicker.setDate(dateToShow, animated: false)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        passBackData()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func passBackData() {
        //print(dateToShow)
        //print(datePicker.date)
        dateToShow = datePicker.date
        delegate?.userDidSelectDate(dateToShow: dateToShow)
    }
}

