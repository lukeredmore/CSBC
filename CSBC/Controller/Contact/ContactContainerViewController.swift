//
//  ContactContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/23/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class ContactContainerViewController: CSBCViewController {

    @IBOutlet weak var schoolPicker: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact"
        if #available(iOS 13.0, *) {
            schoolPicker.overrideUserInterfaceStyle = .dark
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for i in 0..<schoolPicker.numberOfSegments {
            if schoolPicker.titleForSegment(at: i) == schoolSelected.ssString {
                schoolPicker.selectedSegmentIndex = i
                break
            }
        }
    }
    
    func sendData() {
        let CVC = children.last as! ContactParallaxViewController
        CVC.schoolPickerValueDidChange()
    }
    
    @IBAction func schoolPickerValueChanged(_ sender: Any) {
        schoolSelected.update(schoolPicker)
        sendData()
    }
    
}
