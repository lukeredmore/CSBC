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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
    } }
    private var signedOutStudentInfoArray = [StudentPassInfo]() { didSet {
        tableView.isHidden = signedOutStudentInfoArray.count == 0
        tableView.reloadData()
    } }
    private var allStudentInfoArray = [StudentPassInfo]()
    
    private let passDataReference = Database.database().reference().child("PassSystem/Students")
    private var clockTimer : Timer?
    private var gradeLevelMap : [Int:Int] {
        let seniorsGradYear = Calendar.current.component(.year, from: DaySchedule.endDate)
        var gradeLevelMap = [seniorsGradYear : 12]
        for i in stride(from: seniorsGradYear + 1, to: seniorsGradYear + 6, by: 1) {
            gradeLevelMap[i] = gradeLevelMap[i - 1]! - 1
        }
        return gradeLevelMap
    }
    
    
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
            self.allStudentInfoArray.removeAll()
            self.signedOutStudentInfoArray.removeAll()
            
            for (_, student) in studentsDict {
                let studentPassInfo = self.parseStudentForPassInfo(student)
                self.allStudentInfoArray.append(studentPassInfo)
                if studentPassInfo.currentStatus.0.lowercased().contains("out") {
                    self.signedOutStudentInfoArray.append(studentPassInfo)
                }
            }
        }
    }
    private func parseStudentForPassInfo(_ student : [String:Any]) -> StudentPassInfo {
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
    func getGradeLevelString(for student : StudentPassInfo) -> String {
        let gradeLevelString = gradeLevelMap[student.graduationYear] != nil
            ? " (" + gradeLevelMap[student.graduationYear]!.stringValue! + ")"
            : ""
        return gradeLevelString
    }
    
    @IBAction func viewMoreButtonPressed(_ sender: UIButton) {
        print("view more pressed")
        performSegue(withIdentifier: "allStudentPassesSegue", sender: self)
    }
    
    
    //MARK: TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signedOutStudentInfoArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customPassCell") as! PassTableViewCell
        let student = signedOutStudentInfoArray[indexPath.row]

        cell.nameLabel.text = student.name + getGradeLevelString(for: student)
        cell.locationLabel.text = student.currentStatus.0
        
        let interval = Date().timeIntervalSince(student.currentStatus.1)
        let timeString = interval.stringFromTimeInterval()
        cell.timeLabel.text = timeString
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PassDetailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PassDetailSegue",
        let passDetailVC = segue.destination as? PassDetailViewController,
        let index = tableView.indexPathForSelectedRow?.row {
            let student = signedOutStudentInfoArray[index]
            passDetailVC.addLog(for: student)
        } else if segue.identifier == "allStudentPassesSegue",
          let allStudentPassesVC = segue.destination as? AllStudentPassesViewController {
            allStudentPassesVC.addArrayOfStudents(allStudentInfoArray, forGrade: gradeLevelMap)
        }
    }
    
    
    
}
