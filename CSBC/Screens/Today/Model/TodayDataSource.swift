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
    var todaysAthletics: AthleticsModel?
    
    private let sectionNames = ["Events","Sports"]
    
    init(todaysEvents : Set<EventsModel>?, todaysAthletics : AthleticsModel?) {
        self.todaysEventsSet = todaysEvents
        self.todaysAthletics = todaysAthletics
    }
    
    //MARK: TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let todaysEventsCount = todaysEventsSet?.count else { break }
            return todaysEventsCount
        case 1:
            guard let todaysAthleticsCount = todaysAthletics?.title.count else { break }
            return todaysAthleticsCount
        default: break
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todaysEventsArray = todaysEventsSet?.sorted()
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
            if todaysAthletics != nil {
                cell.titleHeightConstraint.constant = 50
                cell.titleLabel.text = todaysAthletics!.title[indexPath.row]
                cell.timeLabel.text = todaysAthletics!.time[indexPath.row]
                cell.levelLabel.text = todaysAthletics!.level[indexPath.row]
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
