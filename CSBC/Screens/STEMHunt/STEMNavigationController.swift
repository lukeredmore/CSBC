//
//  STEMNavigationControllerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/6/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class STEMNavigationController: UINavigationController {

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .flipHorizontal
        viewControllers = [TableLocationViewController()]
        navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.orange,
             NSAttributedString.Key.font: UIFont(name: "DINCondensed-Bold", size: 38)!]
        navigationBar.shadowImage = UIImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        gradient.frame = navigationBar.bounds
        gradient.colors = [UIColor.stemAccentBlue.cgColor, UIColor.stemBaseBlue.cgColor]
        gradient.locations = [0.0, 1.0]

        if let image = getImageFrom(gradientLayer: gradient) {
            navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        }
    }

    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
}
