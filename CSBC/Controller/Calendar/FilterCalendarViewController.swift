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

final class FilterCalendarViewController: UIViewController {
    
    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    @IBOutlet var menuView: UIView!
    @IBOutlet var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var filterSwitches: [UISwitch]!
    
    
    //let menuView = UIView()
    let menuHeight = UIScreen.main.bounds.height / 2
    let button = UIButton()
    var isPresenting = false
    weak var delegate: DataEnteredDelegate? = nil
    var editedSchoolsToShow : [Bool] = []
    var buttonStates : [Bool] = []
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
//        modalPresentationStyle = .custom
//        transitioningDelegate = self
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
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
       
        
//        menuView.backgroundColor = .red
//        menuView.translatesAutoresizingMaskIntoConstraints = false
//        menuView.heightAnchor.constraint(equalToConstant: menuHeight).isActive = true
//        menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FilterCalendarViewController.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for i in 0..<buttonStates.count {
            filterSwitches[i].setOn(buttonStates[i], animated: false)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        passBackData()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func testButton(_ sender: UIButton) {
        
        passBackData()
        
        
    }
    
    
    
    func passBackData() {
        editedSchoolsToShow = [filterSwitches[0].isOn, filterSwitches[1].isOn, filterSwitches[2].isOn, filterSwitches[3].isOn]
        delegate?.userDidSelectSchools(schoolsToShow: editedSchoolsToShow)
    }
}

