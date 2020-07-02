//
//  JumpToDateViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/19/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Shows date selector for date to show in TodayViewController
final class JumpToDateViewController: ModalMenuViewController {
    private let datePicker = UIDatePicker()
    
    weak var delegate: InputUpdateDelegate!
    let dateToShow : Date!
    
    init(dateToShow : Date, delegate : InputUpdateDelegate) {
        self.dateToShow = dateToShow
        self.delegate = delegate
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.setDate(dateToShow, animated: false)
        
        
        let menuView = UIView()
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.addSubview(datePicker)
        menuView.backgroundColor = .csbcCardView
        
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
            menuView.addConstraints([
                datePicker.centerXAnchor.constraint(equalTo: menuView.centerXAnchor)
            ])
            super.init(menu: menuView, height: 310)
        } else {
            menuView.addConstraints([
                datePicker.topAnchor.constraint(equalTo: menuView.topAnchor),
                datePicker.bottomAnchor.constraint(equalTo: menuView.bottomAnchor),
                datePicker.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: menuView.trailingAnchor)
            ])
            super.init(menu: menuView, height: 200)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func passBackData() {
        delegate.storeDateSelected(date: datePicker.date)
    }
}

