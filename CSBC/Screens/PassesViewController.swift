//
//  PassesViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/4/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase


struct StudentPassInfo {
    let name : String
    let graduationYear : Int
    let currentStatus : (String, Date)
    let previousStatuses : [(String, Date)]
}

///Receives from Firebase, parses, and displays students out with passes
class PassesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak private var tableView: UITableView! { didSet {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
    } }
    private var signedOutStudentInfoArray = [StudentPassInfo]() { didSet {
        tableView.isHidden = signedOutStudentInfoArray.count == 0
    } }
    
    private let passDataReference = Database.database().reference().child("PassSystem/Students")
    private var clockTimer : Timer?
    
    
    //MARK: View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        getFirebaseData()
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tableView.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        clockTimer?.invalidate()
        passDataReference.removeAllObservers()
    }
    
    
    //MARK: Data Retrieval
    private func getFirebaseData() {
        passDataReference.observe(.value) { (snapshot) in
            guard let studentsDict = snapshot.value as? [String:[String:Any]] else { return }
            
            self.signedOutStudentInfoArray.removeAll()
            for (_, student) in studentsDict
                where (student["currentStatus"] as? String)?.contains("Out") ?? false {
                    
                let studentPassInfo = self.parseSignedOutStudentForPassInfo(student)
                self.signedOutStudentInfoArray.append(studentPassInfo)
            }
            self.tableView.reloadData()
        }
    }
    private func parseSignedOutStudentForPassInfo(_ student : [String:Any]) -> StudentPassInfo {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        
        let studentLog = student["log"] as? [[String:String]]
        var logToStore = [(String, Date)]()
        for logEntry in studentLog ?? [[String:String]]() {
            guard let statusFromLog = logEntry["status"],
                let dateStringFromLog = logEntry["time"],
                let dateFromLog = dateTimeFormatter.date(from: dateStringFromLog)
                else { continue }
            let logToAdd = (statusFromLog, dateFromLog)
            logToStore.append(logToAdd)
        }
        let timeString = student["timeOfStatusChange"] as! String
        let time = dateTimeFormatter.date(from: timeString)!
        return StudentPassInfo(
            name: student["name"] as! String,
            graduationYear: student["graduationYear"] as! Int,
            currentStatus: (student["currentStatus"] as! String, time),
            previousStatuses: logToStore)
    }
    
    
    //MARK: TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signedOutStudentInfoArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passCell")!
        let student = signedOutStudentInfoArray[indexPath.row]
        
        let seniorsGradYear = Calendar.current.component(.year, from: DaySchedule.endDate)
        var gradeLevelMap = [seniorsGradYear : 12]
        for i in stride(from: seniorsGradYear + 1, to: seniorsGradYear + 6, by: 1) {
            gradeLevelMap[i] = gradeLevelMap[i - 1]! - 1
        }
        let gradeLevelString = gradeLevelMap[student.graduationYear] != nil
            ? " (" + gradeLevelMap[student.graduationYear]!.stringValue! + ")"
            : ""
        cell.textLabel?.text = student.name + gradeLevelString
        
        let interval = Date().timeIntervalSince(student.currentStatus.1)
        let timeString = interval.stringFromTimeInterval()
        cell.detailTextLabel?.text = timeString
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PassDetailSegue", sender: self)
    }
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PassDetailSegue",
        let passDetailVC = segue.destination as? PassDetailViewController,
        let index = tableView.indexPathForSelectedRow?.row {
            
            let student = signedOutStudentInfoArray[index]
            var logToSend : [(String, Date)] = [student.currentStatus]
            for each in student.previousStatuses {
                logToSend.append(each)
            }
            passDetailVC.logToDisplay = convertLogFromFirebaseToNestedArray(logToSend)
            passDetailVC.titleToSet = student.name
        }
    }
    
    func convertLogFromFirebaseToNestedArray(_ log: [(String, Date)]) -> [[(String, Date)]] {
        var tempDict = [String:[(String, Date)]]()
        for entry in log {
            let dateString = entry.1.dateString()
            if tempDict[dateString] != nil {
                tempDict[dateString]?.append(entry)
            } else {
                tempDict[dateString] = [entry]
            }
        }
        return Array(tempDict.values)
    }
    
    
    
}
