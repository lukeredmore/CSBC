//
//  STEMIntroViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/8/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class STEMIntroViewController: UIViewController {

    @IBOutlet weak var upperHeaderImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
        view.backgroundColor = .stemBaseBlue
        view.addVerticalGradient(from: .stemAccentBlue, to: .stemBaseBlue)
        upperHeaderImage.transform = upperHeaderImage.transform.rotated(by: CGFloat(Double.pi))
    }

}
