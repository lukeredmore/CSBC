//
//  ContactContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/23/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit


protocol SchoolSelectedDelegate: class {
    func storeSchoolSelected(schoolSelected: String)
}

class ContactContainerViewController: UIViewController {

    var schoolSelected = ""
    weak var delegate: SchoolSelectedDelegate? = nil
    @IBOutlet weak var schoolPicker: UISegmentedControl!
    
    //MARK: - New school picker properties
    let schoolPickerDictionary : [String:Int] = ["Seton":0,"St. John's":1,"All Saints":2,"St. James":3]
    var schoolSelectedInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact"
        if #available(iOS 13.0, *) {
            schoolPicker.overrideUserInterfaceStyle = .dark
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        schoolSelectedInt = schoolPickerDictionary[schoolSelected] ?? 0
        for i in 0..<schoolPicker.numberOfSegments {
            if schoolPicker.titleForSegment(at: i) == schoolSelected {
                schoolPicker.selectedSegmentIndex = i
                break
            }
        }
        sendData(intToSend: schoolSelectedInt)
    }

    override func viewWillDisappear(_ animated: Bool) {
        delegate?.storeSchoolSelected(schoolSelected: schoolPicker.titleForSegment(at: schoolPicker.selectedSegmentIndex)!)
    }
    
    func sendData(intToSend : Int) {
        let CVC = children.last as! ContactParallaxViewController
        CVC.setSchoolSelectedInContainer(newSchoolSelected: intToSend)
    }
    
    @IBAction func schoolPickerValueChanged(_ sender: Any) {
        schoolSelected = schoolPicker.titleForSegment(at: schoolPicker.selectedSegmentIndex)!
        schoolSelectedInt = schoolPickerDictionary[schoolSelected] ?? 0
        sendData(intToSend: schoolSelectedInt)
        
    }
    
    

    

}
