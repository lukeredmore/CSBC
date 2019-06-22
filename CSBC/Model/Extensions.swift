//
//  Extensions.swift
//  CSBC
//
//  Created by Luke Redmore on 3/10/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension UIColor {
    static var csbcGreen: UIColor  {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCNavBarBackground")!
        } else {
            return UIColor(red: 21/255, green: 71/255, blue: 52/255, alpha: 1)
        }
    }
    static var csbcGreenForSafariViewController: UIColor { return UIColor(hue: 152/360, saturation: 100/100, brightness: 20/100, alpha: 1) }
    static var csbcAlertRed: UIColor { return UIColor(red: 221/255, green: 51/255, blue: 51/255, alpha: 1.0) }
    static var csbcYellow: UIColor { return UIColor(red: 246/255, green: 190/255, blue: 0/255, alpha: 1.0) }
    static var csbcSuperLightGray: UIColor { return UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0) }
    static var csbcLightGreen: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCLightGreen")!
        } else {
            return UIColor(red: 44/255, green: 117/255, blue: 90/255, alpha: 1.0) }
        }
}

extension UISearchBar {
    var searchField: UITextField {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            return subviews.first?.subviews.first(where: { $0.isKind(of: UITextField.self) }) as! UITextField
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}
//extension UIViewController {
//    /**
//     *  Height of status bar + navigation bar (if navigation bar exist)
//     */
//    var topBarHeight: CGFloat {
//        return UIApplication.shared.statusBarFrame.size.height +
//            (self.navigationController?.navigationBar.frame.height ?? 0.0)
//    }
//}

extension FilterCalendarViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            menuView.frame.origin.y += menuHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                self.menuView.frame.origin.y -= self.menuHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                self.menuView.frame.origin.y += self.menuHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
extension FilterAlertsViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting.toggle()
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            menuView.frame.origin.y += menuHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                self.menuView.frame.origin.y -= self.menuHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                self.menuView.frame.origin.y += self.menuHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
extension SetDeliveryTimeViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            menuView.frame.origin.y += menuHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                self.menuView.frame.origin.y -= self.menuHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut], animations: {
                self.menuView.frame.origin.y += self.menuHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
extension UIView {
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        //clipsToBounds = false
    }
}
extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
extension UIViewController {
    func shouldIShowAllSchools(schoolPicker : UISegmentedControl, schoolPickerHeightConstraint : NSLayoutConstraint) {
        if #available(iOS 13.0, *) {
            schoolPicker.overrideUserInterfaceStyle = .dark
        }
        let schoolNames = ["Seton","St. John's","All Saints","St. James"]
        let internalNotificationSettings = defineNotificationSettings()
        if let showAllSchools : Bool = UserDefaults.standard.value(forKey: "showAllSchools") as! Bool? {
            if showAllSchools {
                schoolPicker.removeAllSegments()
                for i in 0..<schoolNames.count {
                    schoolPicker.insertSegment(withTitle: schoolNames[i], at: i, animated: false)
                }
                schoolPickerHeightConstraint.constant = 45
                schoolPicker.isHidden = false
            } else {
                let schoolBools : [Bool] = internalNotificationSettings.schools
                //print(editedSchoolNames)
                schoolPicker.removeAllSegments()
                var indexAtWhichToInsertSegment = 0
                for i in 0..<schoolBools.count {
                    if schoolBools[i] {
                        schoolPicker.insertSegment(withTitle: schoolNames[i], at: indexAtWhichToInsertSegment, animated: false)
                        indexAtWhichToInsertSegment += 1
                        //print("thing inserted at \(i)")
                        //print("thing again inserted at \(indexAtWhichToInsertSegment)")
                    }
                }
                if schoolPicker.numberOfSegments == 1 {
                    schoolPickerHeightConstraint.constant = 0
                    schoolPicker.isHidden = true
                } else {
                    schoolPickerHeightConstraint.constant = 45
                    schoolPicker.isHidden = false
                }
                view.layoutIfNeeded()
            }
        } else {
            schoolPicker.removeAllSegments()
            for i in 0..<schoolNames.count {
                schoolPicker.insertSegment(withTitle: schoolNames[i], at: i, animated: false)
            }
            schoolPickerHeightConstraint.constant = 45
            schoolPicker.isHidden = false
        }
    }
    func defineNotificationSettings() -> NotificationSettings {
        if let data = UserDefaults.standard.value(forKey:"Notifications") as? Data {
            let notificationSettings = try? PropertyListDecoder().decode(NotificationSettings.self, from: data)
            return notificationSettings!
        } else {
            let notificationSettings = NotificationSettings(shouldDeliver: true, deliveryTime: "7:00 AM", schools: [true, true, true, true], valuesChangedByUser: false)
            return notificationSettings
        }
    }
}

extension UserDefaults {
    
    /**
     Sets the value of the specified default key to the specified codable object (such as dictionaries with non-String keys).
     */
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    /**
     Returns the codable object associated with the specified key.
     */
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}


