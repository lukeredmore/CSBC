//
//  Extensions.swift
//  CSBC
//
//  Created by Luke Redmore on 3/10/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import SafariServices

extension UIColor {
    ///Light: System light gray; Dark: Black
    static var csbcAccentGray: UIColor { return UIColor(named: "CSBCAccentGray")! }
    
    ///Universal: Nice-looking red
    static var csbcAlertRed: UIColor { return UIColor(named: "CSBCAlertRed")! }
    
    ///Light: White; Dark: Black
    static var csbcBackground: UIColor { return UIColor(named: "CSBCBackground")! }
    
    ///Light: White; Dark: Dark gray
    static var csbcCardView: UIColor { return UIColor(named: "CSBCCardView")! }
    
    ///Light: Black; Dark: White
    static var csbcDefaultText: UIColor { return UIColor(named: "CSBCDefaultText")! }
    
    ///Light: 666 gray; Dark: White
    static var csbcGrayLabel: UIColor { return UIColor(named: "CSBCGrayLabel")! }
    
    ///Light: Light CSBC green; Dark: Dark gray
    static var csbcLightGreen: UIColor { return UIColor(named: "CSBCLightGreen")! }
    
    ///Light: CSBC green; Dark: Black
    static var csbcNavBarBackground: UIColor  { return UIColor(named: "CSBCNavBarBackground")! }
    
    ///Light: CSBC green; Dark: Dark gray
    static var csbcNavBarFlipside: UIColor { return UIColor(named: "CSBCNavBarFlipside")! }
    
    ///Light: White; Dark: CSBC green, slightly lightened
    static var csbcNavBarText: UIColor { return UIColor(named: "CSBCNavBarText")! }

    ///Light: CSBC green modified for SFSafariVC; Dark: Black
    static var csbcSafariVCBar: UIColor { return UIColor(named: "CSBCSafariVCBar")! }
    
    ///Universal: Logo yellow
    static var csbcYellow: UIColor { return UIColor(named: "CSBCYellow")! }
}

extension UISearchBar {
    var searchField: UITextField {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            return subviews.first?.subviews.first { $0.isKind(of: UITextField.self) } as! UITextField
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
        self.preferredBarTintColor = .csbcSafariVCBar
        self.preferredControlTintColor = .csbcNavBarText
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
    ///Returns "yyyy" (2001)
    func yearString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy"
        return fmt.string(from: self)
    }
    ///Returns "MM" (02)
    func monthNumberString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM"
        return fmt.string(from: self)
    }
    ///Returns "MMMM" (February)
    func monthNameString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM"
        return fmt.string(from: self)
    }
    ///Returns "MMM" (Mar)
    func monthAbbreviationString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        return fmt.string(from: self)
    }
    ///Returns "MMMM yyyy" (December 2012)
    func monthYearString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: self)
    }
    ///Returns "dd" (02)
    func dayString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd"
        return fmt.string(from: self)
    }
    
    ///Returns "MM/dd/yyyy" (01/09/2002)
    func dateString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt.string(from: self)
    }
    /// Returns "MM/dd/yyyy HH:mm:ss" (01/09/02 23:55:02)
    func dateStringWithTime() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return fmt.string(from: self)
    }
    ///Returns "hh:mm a" (01:14 PM)
    func timeString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "hh:mm a"
        return fmt.string(from: self)
    }
    ///Returns "EEEE" (Monday)
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
    ///Returns date if self is formatted as "MM/dd/yyyy HH:mm:ss"
    func toDateWithTime() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return dateFormatter.date(from: self)
    }
    ///Returns date if self is formatted as "MMM"
    func toDateWithMonth() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.date(from: self)
    }
}
extension Int {
    var stringValue : String? {
        return String(self)
    }
}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        Calendar.current.date(from: lhs)! < Calendar.current.date(from: rhs)!
    }
}

