//
//  TodayDataSource.swift
//  CSBC
//
//  Created by Luke Redmore on 8/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Populates TodayViewController with pre-parsed data received by TodayViewController
class TodayDataSource: NSObject, UITableViewDataSource, UITextViewDelegate {
    private let notesSample = "Enter any notes for today"
    private var expectedPlaceholderColor : UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return .darkGray
        }
    }
    
    private var todaysEventsArray : Array<EventsModel>?
    private var todaysAthleticsArray: Array<AthleticsModel>?
    private var date : Date!
    
    init(todaysEvents : Set<EventsModel>?, todaysAthletics : Set<AthleticsModel>?, date : Date) {
        self.todaysEventsArray = todaysEvents?.sorted()
        self.todaysAthleticsArray = todaysAthletics?.sorted()
        self.date = date
    }
    
    //MARK: TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int { 3 }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { ["Events","Sports","My Notes"][section] }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let todaysEventsCount = todaysEventsArray?.count else { break }
            return todaysEventsCount
        case 1:
            guard let todaysAthleticsCount = todaysAthleticsArray?.count else { break }
            return todaysAthleticsCount
        case 2:
            return 1
        default: break
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0, 1:
            return createBodyCell(tableView, cellForRowAt: indexPath)
        case 2:
            return createTextCell(tableView, cellForRowAt: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    private func createBodyCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TodayViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todayViewCell") as? TodayViewCell else { return TodayViewCell() }
        if #available(iOS 13.0, *) {
            cell.titleLabel.textColor = .label
            cell.levelLabel.textColor = .secondaryLabel
            cell.timeLabel.textColor = .secondaryLabel
        } else {
            cell.titleLabel.textColor = .darkText
            cell.levelLabel.textColor = .darkText
            cell.timeLabel.textColor = .darkText
        }
        if indexPath.section == 1 {
            if let todaysAthleticsArray = todaysAthleticsArray {
                cell.titleHeightConstraint.constant = 50
                cell.titleLabel.text = todaysAthleticsArray[indexPath.row].title
                cell.timeLabel.text = todaysAthleticsArray[indexPath.row].time
                cell.levelLabel.text = todaysAthleticsArray[indexPath.row].level
            } else {
                cell.timeLabel.text = "There are no events today"
                cell.titleLabel.text = nil
                cell.levelLabel.text = nil
                cell.titleHeightConstraint.constant = 33
            }
        } else {
            if let todaysEventsArray = todaysEventsArray {
                cell.titleHeightConstraint.constant = 50
                cell.titleLabel.text = todaysEventsArray[indexPath.row].event
                cell.timeLabel.text = todaysEventsArray[indexPath.row].time
                cell.levelLabel.text = todaysEventsArray[indexPath.row].schools
            } else {
                cell.timeLabel.text = "There are no events today"
                cell.titleLabel.text = nil
                cell.levelLabel.text = nil
                cell.titleHeightConstraint.constant = 33
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    private func createTextCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TodayTextViewTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTextViewTableViewCell") as? TodayTextViewTableViewCell else { return TodayTextViewTableViewCell() }
        if let existingNote = UserDefaults.standard.string(forKey: date.dateString()) {
            cell.textView.text = existingNote
            cell.textView.textColor = .csbcDefaultText
        } else {
            cell.textView.text = notesSample
            cell.textView.textColor = expectedPlaceholderColor
        }
        if #available(iOS 13.0, *) {
            cell.textView.backgroundColor = .secondarySystemGroupedBackground
        } else {
            cell.textView.backgroundColor = .white
        }
        cell.textView.tintColor = .csbcYellow
        cell.textView.keyboardDismissMode = .onDrag
        cell.textView.delegate = self
        return cell
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if "\(textView.text!)" == notesSample && textView.textColor == expectedPlaceholderColor {
            textView.text = ""
            textView.textColor = .csbcDefaultText
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if "\(textView.text!)" == "" || "\(textView.text!)" == notesSample {
            textView.text = notesSample
            textView.textColor = expectedPlaceholderColor
            UserDefaults.standard.set(nil, forKey: date.dateString())
        } else {
            UserDefaults.standard.set(textView.text, forKey: date.dateString())
        }
    }
    
}
