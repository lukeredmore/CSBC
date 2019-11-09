//
//  SnowFallView.swift
//  CSBC
//
//  Created by Luke Redmore on 11/8/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit


class SnowFallView: UIView {
    
    private let flakesCount = 20
    private let flakeFileName = "snowflake"
    private let flakeMinimumSize: CGFloat = 20.0
    private let flakeMaximumSize: CGFloat = 45.0
    
    private let animationDurationMin: CGFloat = 2.0
    private let animationDurationMax: CGFloat = 3.5
    
    private var flakesArray = [UIImageView]()
    
    private let count : Float!
    private let completion : (() -> Void)?
    
    static func overlay(onView superV: UIView, count: Int, completion : (() -> Void)? = nil) {
        let v = SnowFallView(frame: superV.bounds, count: count, completion: completion)
        superV.addSubview(v)
        v.startSnow()
    }
    
    init(frame: CGRect, count : Int, completion : (() -> Void)? = nil) {
        self.count = Float(count)
        self.completion = completion
        super.init(frame: frame)
        createFlakes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func createFlakes() {
        backgroundColor = .clear
        flakesArray.removeAll()
        let flakeImage = UIImage(named: flakeFileName)!
        for _ in 0..<flakesCount {
            let size = CGFloat.random(in: flakeMinimumSize...flakeMaximumSize)
            let vx = CGFloat.random(in: 0...frame.size.width)
            let vy = CGFloat.random(in: -150 ..< -50)
            
            let imageFrame = CGRect(x: 0, y: 0, width: size, height: size)
            let imageView = UIImageView(image: flakeImage)
            imageView.frame = imageFrame
            imageView.center = CGPoint(x: vx, y: vy)
            imageView.isUserInteractionEnabled = false
            flakesArray.append(imageView)
            addSubview(imageView)
        }
    }
    
    func startSnow() {
        
        
        let rotAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotAnimation.repeatCount = Float.infinity
        rotAnimation.isCumulative = true
        rotAnimation.autoreverses = false
        rotAnimation.toValue = 6.28318531
        
        let transAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        transAnimation.repeatCount = count
        transAnimation.autoreverses = false
        
        for v in flakesArray {
            
            Timer.scheduledTimer(withTimeInterval: CFTimeInterval.random(in: 0...3), repeats: false) { _ in
                let timeInterval = CGFloat.random(in: self.animationDurationMin...self.animationDurationMax)
                transAnimation.duration = CFTimeInterval(timeInterval)
                let const = v.center.y < 0 ? -v.center.y : 0
                transAnimation.fromValue = v.center.y
                transAnimation.toValue = self.frame.size.height + const + 40
                
                CATransaction.begin()
                CATransaction.setCompletionBlock(self.firstCompletion)
                v.layer.add(transAnimation, forKey: "transAnimation")
                CATransaction.commit()
                
                rotAnimation.duration = CFTimeInterval(CGFloat.random(in: 1.5...3) * timeInterval)
                v.layer.add(rotAnimation, forKey: "rotAnimation")
                
                Timer.scheduledTimer(withTimeInterval: CFTimeInterval(CGFloat(Int.random(in: 1...3)) * timeInterval), repeats: true) { _ in
                    let size = CGFloat.random(in: self.flakeMinimumSize...self.flakeMaximumSize)
                    let cent = v.center
                    v.frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
                    v.center = CGPoint(x: CGFloat.random(in: 0...self.frame.size.width), y: cent.y)
                }
            }
            
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.frame.contains(point) {
                return true
            }
        }
        return false
    }
    
    private var resetCount = 0
    func firstCompletion() {
        resetCount += 1
        if resetCount == flakesArray.count {
            completion?()
            for v in flakesArray {
                v.layer.removeAllAnimations()
            }
            flakesArray.removeAll()
            resetCount = 0
            removeFromSuperview()
        }
    }
}
