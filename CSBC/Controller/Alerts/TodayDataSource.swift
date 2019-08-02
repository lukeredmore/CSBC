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
    var todaysEvents: [EventsModel] = []
    var todaysAthletics: AthleticsModel? = nil
    
    let sectionNames = ["Events","Sports"]
    
    
    //MARK: TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if todaysEvents.count != 0 {
                return todaysEvents.count
            } else {
                return 1
            }
        } else {
            if todaysAthletics != nil {
                return todaysAthletics!.title.count
            } else {
                return 1
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            if todaysEvents.count > 0 {
                cell.titleHeightConstraint.constant = 50
                cell.titleLabel.text = todaysEvents[indexPath.row].event
                cell.timeLabel.text = todaysEvents[indexPath.row].time
                cell.levelLabel.text = todaysEvents[indexPath.row].schools
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
