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
import SafariServices

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

extension UIView {
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        //clipsToBounds = false
    }
}
extension SFSafariViewController {
    func configureForCSBC() {
        self.preferredBarTintColor = UIColor(named: "CSBCNavBarBackground")!
        self.preferredControlTintColor = UIColor(named: "CSBCNavBarText")!
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .overCurrentContext
    }
}
extension UserDefaults {
    
    /**
    Returns the codable object associated with the specified key.
    */
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    /**
    Sets the value of the specified default key to the specified codable object (such as dictionaries with non-String keys).
    */
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}

extension Date {
    
    func yearString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy"
        return fmt.string(from: self)
    }
    func monthNumberString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM"
        return fmt.string(from: self)
    }
    func monthNameString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM"
        return fmt.string(from: self)
    }
    func monthAbbreviationString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        return fmt.string(from: self)
    }
    func monthYearString() -> String {
            let fmt = DateFormatter()
            fmt.dateFormat = "MMMM yyyy"
            return fmt.string(from: self)
        }
    func dayString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd"
        return fmt.string(from: self)
    }
    func dateString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt.string(from: self)
    }
    func dateStringWithTime() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return fmt.string(from: self)
    }
    func timeString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "hh:mm a"
        return fmt.string(from: self)
    }
    func dayOfWeekString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE"
        return fmt.string(from: self)
    }
}

extension String {
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0.self.count > 0 {
                    return ($0 + " " + String($1))
                }
            }
            return $0 + String($1)
        }
    }
    func toDateWithTime() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return dateFormatter.date(from: self)
    }
}

