//
//  TestVC.swift
//  CSBC
//
//  Created by Luke Redmore on 7/6/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class TestVC: CSBCViewController {

    @IBOutlet weak var imageView: UIImageView!
    let buildingImageArray = ["setonBuilding","johnBuilding","saintsBuilding","jamesBuilding"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [imageView])
    }
    
    override func schoolPickerValueChanged(_ sender: CSBCSegmentedControl) {
        super.schoolPickerValueChanged(sender)
        imageView.image = UIImage(named: buildingImageArray[schoolSelected.ssInt])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
