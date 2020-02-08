//
//  CSBCNavigationController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/7/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class CSBCNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = .csbcNavBarBackground
        navigationBar.tintColor = .csbcNavBarText
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "gotham", size: 30)!,
            NSAttributedString.Key.foregroundColor: UIColor.csbcNavBarText
        ]
        
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
}
