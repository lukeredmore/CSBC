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
    static var csbcAccentGray: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCAccentGray")!
        } else { return #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1) }
    }
    
    ///Light: Custom gray; Dark: Custom gray, but a little lighter
    static var csbcAlwaysGray: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCAlwaysGray")!
        } else { return #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) }
    }
    
    ///Universal: Nice-looking red
    static var csbcAlertRed: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCAlertRed")!
        } else { return #colorLiteral(red: 0.8666666667, green: 0.2, blue: 0.2, alpha: 1) }
    }
    
    ///Light: White; Dark: Black
    static var csbcBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCBackground")!
        } else { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    }
    
    ///Light: White; Dark: Dark gray
    static var csbcCardView: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCCardView")!
        } else { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    }
    
    ///Light: Black; Dark: White
    static var csbcDefaultText: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCDefaultText")!
        } else { return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) }
    }
    
    ///Light: 666 gray; Dark: White
    static var csbcGrayLabel: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCGrayLabel")!
        } else { return #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) }
    }
    
    ///Light: Light CSBC green; Dark: Dark gray
    static var csbcLightGreen: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCLightGreen")!
        } else { return #colorLiteral(red: 0.1725490196, green: 0.4588235294, blue: 0.3529411765, alpha: 1) }
    }
    
    ///Light: CSBC green; Dark: Black
    static var csbcNavBarBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCNavBarBackground")!
        } else { return #colorLiteral(red: 0.08235294118, green: 0.2784313725, blue: 0.2039215686, alpha: 1) }
    }
    
    ///Light: CSBC green; Dark: Dark gray
    static var csbcNavBarFlipside: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCNavBarFlipside")!
        } else { return #colorLiteral(red: 0.08235294118, green: 0.2784313725, blue: 0.2039215686, alpha: 1) }
    }
    
    ///Light: White; Dark: CSBC green, slightly lightened
    static var csbcNavBarText: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCNavBarText")!
        } else { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    }
    
    ///Light: CSBC green modified for SFSafariVC; Dark: Black
    static var csbcSafariVCBar: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCSafariVCBar")!
        } else { return #colorLiteral(red: 0, green: 0.2, blue: 0.1058823529, alpha: 1) }
    }
    
    ///Light: System table separator; Dark: System table separator
    static var csbcTableSeparator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCTableSeparator")!
        } else { return #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1) }
    }
    
    ///Universal: Logo yellow
    static var csbcYellow: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(named: "CSBCYellow")!
        } else { return #colorLiteral(red: 0.9647058824, green: 0.7450980392, blue: 0, alpha: 1) }
    }
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
    ///Removes capitals, commas, and apostrophes
    func configureForSearch() -> String {
        return self.lowercased()
        .replacingOccurrences(of: ",", with: "")
        .replacingOccurrences(of: "'", with: "")
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

extension Date: Strideable {
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
    
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }
    public func advanced(by n: TimeInterval) -> Date {
        return self + n
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

extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        if hours > 0 {
            return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        } else {
            return String(format: "%0.2d:%0.2d",minutes,seconds)
        }
    }
}

extension Set where Element : Searchable {
    func nest<T: Searchable>() -> [[T]] {
        let arr = self.sorted() as! [T]
        var dictToFlatten : Dictionary<AnyHashable,[T]> = [:]
        for each in arr {
            guard let paramToGroupBy = each.groupIntoSectionsByThisParameter else { return [arr] }
            if dictToFlatten[paramToGroupBy] != nil {
                dictToFlatten[paramToGroupBy]?.append(each)
            } else {
                dictToFlatten[paramToGroupBy] = [each]
            }
        }
        dictToFlatten = dictToFlatten.mapValues { $0.sorted() }
        return Array(dictToFlatten.values).sorted { (T.sortSectionsByThisParameter($0[0], $1[0]) ?? true) }
        
    }
}
