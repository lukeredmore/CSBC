//
//  STEMSuccessViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/7/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class STEMSuccessViewController: UIViewController {

    @IBOutlet weak var upsideDownImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
        view.backgroundColor = .stemBaseBlue
        view.addVerticalGradient(from: .stemAccentBlue, to: .stemBaseBlue)
        upsideDownImage.transform = upsideDownImage.transform.rotated(by: CGFloat(Double.pi))
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
