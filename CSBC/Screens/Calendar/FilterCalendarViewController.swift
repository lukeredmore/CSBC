//
//  FilterCalendarViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol DataEnteredDelegate: class {
    func userDidSelectSchools(schoolsToShow: [Bool])
}

final class FilterCalendarViewController: ModalMenuViewController {
    
    @IBOutlet private var menuView: UIView!
    @IBOutlet private var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var filterSwitches: [UISwitch]!
    
    //private let menuView = UIView()
    private let button = UIButton()
    weak var delegate: DataEnteredDelegate? = nil
    private var editedSchoolsToShow : [Bool] = []
    var buttonStates : [Bool] = []
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuView(menuView)
    }
    override func viewWillAppear(_ animated: Bool) {
        for i in buttonStates.indices {
            filterSwitches[i].setOn(buttonStates[i], animated: false)
        }
    }
    override func passBackData() { //called before view dismiss
        editedSchoolsToShow = [filterSwitches[0].isOn, filterSwitches[1].isOn, filterSwitches[2].isOn, filterSwitches[3].isOn]
        delegate?.userDidSelectSchools(schoolsToShow: editedSchoolsToShow)
    }
}

