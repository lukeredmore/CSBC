//
//  ModalPickerViewController.swift
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

///Modal VC where both the notification delivery time and day override can be picked
final class ModalPickerViewController: ModalMenuViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak private var menuView: UIView!
    @IBOutlet weak private var menuViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var timePicker: UIDatePicker!
    weak private var timeEnteredDelegate: TimeEnteredDelegate?
    private var timeToShow : Date?
    
    @IBOutlet weak private var dayPicker: UIPickerView!
    weak private var dayOverrideDelegate: DayOverriddenDelegate?
    private var dayToShow : Int?
    
    
    //MARK: Init Methods
    static func instantiateForDayOverride(delegate : DayOverriddenDelegate, dayToShow : Int) -> ModalPickerViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetDeliveryTimeViewScene") as! ModalPickerViewController
        vc.dayOverrideDelegate = delegate
        vc.dayToShow = dayToShow
        return vc
    }
    static func instantiateForTime(delegate : TimeEnteredDelegate, timeToShow : Date) -> ModalPickerViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetDeliveryTimeViewScene") as! ModalPickerViewController
        vc.timeEnteredDelegate = delegate
        vc.timeToShow = timeToShow
        return vc
    }
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuView(menuView)
    }
    override func viewWillAppear(_ animated: Bool) {
        if timeEnteredDelegate != nil, timeToShow != nil {
            dayOverrideDelegate = nil
            timePicker.isEnabled = true
            timePicker.isHidden = false
            dayPicker.isHidden = true
            timePicker.date = timeToShow!
            dayPicker.dataSource = nil
            dayPicker.delegate = nil
        }
        if dayOverrideDelegate != nil, dayToShow != nil {
            timeEnteredDelegate = nil
            dayPicker.isHidden = false
            dayPicker.dataSource = self
            dayPicker.delegate = self
            dayPicker.reloadAllComponents()
            dayPicker.selectRow(dayToShow! - 1, inComponent: 0, animated: false)
            timePicker.isEnabled = false
            timePicker.isHidden = true
        }
    }
    override func passBackData() { //called before view disappears
        if timeEnteredDelegate != nil && dayOverrideDelegate == nil {
            timeEnteredDelegate?.userDidSelectTime(timeToShow: timePicker.date)
        }
        if timeEnteredDelegate == nil && dayOverrideDelegate != nil {
            let day = dayPicker.selectedRow(inComponent: 0) + 1
            dayOverrideDelegate?.adminDidOverrideDay(day: day)
        }
    }

    //MARK: Delegate Methods For Day Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 6
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
}



