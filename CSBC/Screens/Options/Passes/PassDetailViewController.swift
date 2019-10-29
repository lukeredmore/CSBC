//
//  PassDetailViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/4/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Shows past pass activity with data from parent VC (PassesViewController)
class PassDetailViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak private var explicitNavItem: UINavigationItem!
    @IBOutlet weak private var tableView : UITableView! { didSet {
        explicitNavItem.title = studentName
        tableView.dataSource = self
        tableView.reloadData()
    }}
    
    private var logToDisplay = [[(String, Date)]]()
    private var studentName = String()
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addLog(for student : StudentPassInfo) {
        studentName = student.name
        var logToConvert : [(String, Date)] = [student.currentStatus]
        logToConvert += student.previousStatuses
        var tempDict = [String:[(String, Date)]]()
        for entry in logToConvert {
            let dateString = entry.1.dateString()
            if tempDict[dateString] != nil {
                tempDict[dateString]?.append(entry)
            } else {
                tempDict[dateString] = [entry]
            }
        }
        logToDisplay = Array(tempDict.values).map { $0.sorted { $0.1 > $1.1 } }
        logToDisplay.sort { $0[0].1 > $1[0].1  }
    }
    
    //MARK: TableView Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        logToDisplay.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logToDisplay[section].count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: logToDisplay[section][0].1)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let logEntry = logToDisplay[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PassLogCell")!
        cell.textLabel?.text = timeFormatter.string(from: logEntry.1)
        cell.detailTextLabel?.text = logEntry.0.replacingOccurrences(of: "Signed ", with: "")
        return cell
    }
    
}