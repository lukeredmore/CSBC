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
    
    weak var delegate: InputUpdateDelegate!
    var dateToShow = Date()
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuView(menuView)
    }
    override func viewWillAppear(_ animated: Bool) {
        datePicker.setDate(dateToShow, animated: false)
    }
    override func passBackData() {
        delegate.storeDateSelected(date: datePicker.date)
    }
}

