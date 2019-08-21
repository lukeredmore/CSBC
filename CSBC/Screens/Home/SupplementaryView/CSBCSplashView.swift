//
//  CSBCSplashView.swift
//  CSBC
//
//  Created by Luke Redmore on 7/29/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UIKit


/// SplashView that reveals its content and animate, like twitter
open class CSBCSplashView: UIView {
    
    private var imageView = UIImageView()
    
    
    //MARK: Constructor
    /**
     Default constructor of the class
     
     - parameter addToView:       The view to which the splash view should be added
     - returns: The created CSBCSplashViewObject
     */
    init(addToView parentView: UIView)
    {
        super.init(frame: (UIScreen.main.bounds))
        
        imageView.image = UIImage(named: "lettermark")
        imageView.frame = CGRect(x: 0, y: 0, width: 128, height: 128)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.center = self.center
        
        self.addSubview(imageView)
        
        self.backgroundColor = .csbcBackground
        parentView.addSubview(self)
        
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Animations
    func startAnimation() {
        //Shrink animation
        UIView.animate(withDuration: 0.45, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: [], animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        })
        
        //Zoom out animation
        UIView.animate(withDuration: 0.45, delay: 0.95, options: [], animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 20, y: 20)
            self.alpha = 0
        }) { finished in self.removeFromSuperview() }
    }
    
}


