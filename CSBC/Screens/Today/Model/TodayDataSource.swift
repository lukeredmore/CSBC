//
//  TodayDataSource.swift
//  CSBC
//
//  Created by Luke Redmore on 8/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Populates TodayViewController with pre-parsed data received by TodayViewController
class TodayDataSource: NSObject, UITableViewDataSource {
    var todaysEventsSet : Set<EventsModel>?
    var todaysAthleticsSet: Set<AthleticsModel>?
    
    init(todaysEvents : Set<EventsModel>?, todaysAthletics : Set<AthleticsModel>?) {
        self.todaysEventsSet = todaysEvents
        self.todaysAthleticsSet = todaysAthletics
    }
    
    //MARK: TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { ["Events","Sports"][section] }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let todaysEventsCount = todaysEventsSet?.count else { break }
            return todaysEventsCount
        case 1:
            guard let todaysAthleticsCount = todaysAthleticsSet?.count else { break }
            return todaysAthleticsCount
        default: break
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todaysEventsArray = todaysEventsSet?.sorted()
        let todaysAthleticsArray = todaysAthleticsSet?.sorted()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todayViewCell") as? TodayViewCell else { return UITableViewCell() }
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
    
}
