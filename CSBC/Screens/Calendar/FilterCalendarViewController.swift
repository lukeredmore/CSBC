//
//  FilterCalendarViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Provides UI to toggle schools to show/hide in CalendarTableViewController
final class FilterCalendarViewController: ModalMenuViewController {
    let completion : (([Bool]) -> Void)!
    var filterSwitches = [UISwitch]()
    
    
    init(currentlyShownSchools : [Bool], completion : @escaping (([Bool]) -> Void)) {
        self.completion = completion
        
        let titleL = UILabel()
        titleL.text = "Show Events For:"
        titleL.textColor = .csbcDefaultText
        titleL.font = UIFont(name: "Montserrat-SemiBold", size: 24)
        titleL.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 0..<4 {
            let filtSwitch = UISwitch()
            filtSwitch.isOn = currentlyShownSchools[i]
            filterSwitches.append(filtSwitch)
        }
        
        var lblarr : [UILabel] = []
        for each in ["Seton","St. John's","All Saints","St. James"] {
            let scl = UILabel()
            scl.text = each
            scl.textColor = .csbcDefaultText
            scl.textAlignment = .right
            scl.font = UIFont(name: "Montserrat-SemiBold", size: 17)
            lblarr.append(scl)
        }
        
        let labelStack = UIStackView(arrangedSubviews: lblarr)
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.alignment = .fill
        labelStack.distribution = .equalSpacing
        labelStack.axis = .vertical
        labelStack.spacing = 0
        
        let switchStack = UIStackView(arrangedSubviews: filterSwitches)
        switchStack.translatesAutoresizingMaskIntoConstraints = false
        switchStack.alignment = .fill
        switchStack.distribution = .equalSpacing
        switchStack.axis = .vertical
        switchStack.spacing = 0
        
        let menuView = UIView()
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.addSubview(titleL)
        menuView.addSubview(switchStack)
        menuView.addSubview(labelStack)
        menuView.addConstraints([
            titleL.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 25),
            titleL.heightAnchor.constraint(equalToConstant: 30),
            titleL.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 25),
            titleL.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: 25)
        ])
        menuView.addConstraints([
            switchStack.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 70),
            switchStack.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -50),
            switchStack.widthAnchor.constraint(equalToConstant: 51),
            switchStack.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -40)
        ])
        menuView.addConstraints([
            labelStack.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 75),
            labelStack.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -55),
            labelStack.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 50),
            labelStack.trailingAnchor.constraint(equalTo: switchStack.leadingAnchor, constant: -10)
        ])
        menuView.backgroundColor = .csbcCardView
        super.init(menu: menuView, height: 350)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func passBackData() {
        let editedSchoolsToShow = [filterSwitches[0].isOn, filterSwitches[1].isOn, filterSwitches[2].isOn, filterSwitches[3].isOn]
        completion(editedSchoolsToShow)
    }
}

