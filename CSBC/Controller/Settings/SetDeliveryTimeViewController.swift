//
//  SetDeliveryTimeViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/25/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

//
//  FilterAlertsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/19/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol TimeEnteredDelegate: class {
    func userDidSelectTime(timeToShow: Date)
}

protocol DayOverriddenDelegate: class {
    func adminDidOverrideDay(day: Int)
}

final class SetDeliveryTimeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var dayPicker: UIPickerView!
    
    
    //let menuView = UIView()
    let menuHeight = UIScreen.main.bounds.height / 2
    var isPresenting = false
    weak var delegate: TimeEnteredDelegate? = nil
    weak var dayOverrideDelegate: DayOverriddenDelegate? = nil
    var timeToShow = Date()
    var overrideDaySelected = 0
    var dayToShow = 0
    
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
        
        
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        view.addSubview(menuView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SetDeliveryTimeViewController.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        passBackData()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func passBackData() {
        if delegate != nil && dayOverrideDelegate == nil {
            delegate?.userDidSelectTime(timeToShow: timePicker.date)
        }
        if delegate == nil && dayOverrideDelegate != nil {
            dayOverrideDelegate?.adminDidOverrideDay(day: overrideDaySelected)
        }
    }

    
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



