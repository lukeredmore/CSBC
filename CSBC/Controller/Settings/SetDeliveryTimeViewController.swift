//
//  SetDeliveryTimeViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/25/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol TimeEnteredDelegate: class {
    func userDidSelectTime(timeToShow: Date)
}
protocol DayOverriddenDelegate: class {
    func adminDidOverrideDay(day: Int)
}

final class SetDeliveryTimeViewController: ModalMenuViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var dayPicker: UIPickerView!
    
    weak var delegate: TimeEnteredDelegate? = nil
    weak var dayOverrideDelegate: DayOverriddenDelegate? = nil
    var timeToShow = Date()
    var overrideDaySelected = 0
    var dayToShow = 0

    //MARK: View control
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuView(menuView)
    }
    override func viewWillAppear(_ animated: Bool) {
        if delegate != nil {
            dayOverrideDelegate = nil
            timePicker.isEnabled = true
            timePicker.isHidden = false
            dayPicker.isHidden = true
            dayPicker.dataSource = nil
            dayPicker.delegate = nil
        }
        if dayOverrideDelegate != nil {
            delegate = nil
            dayPicker.isHidden = false
            dayPicker.dataSource = self
            dayPicker.delegate = self
            dayPicker.reloadAllComponents()
            dayPicker.selectRow(dayToShow, inComponent: 0, animated: false)
            timePicker.isEnabled = false
            timePicker.isHidden = true
        }
    }
    override func passBackData() { //called before view disappears
        if delegate != nil && dayOverrideDelegate == nil {
            delegate?.userDidSelectTime(timeToShow: timePicker.date)
        }
        if delegate == nil && dayOverrideDelegate != nil {
            dayOverrideDelegate?.adminDidOverrideDay(day: overrideDaySelected)
        }
    }

    //MARK: Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        overrideDaySelected = row
 
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    

}



