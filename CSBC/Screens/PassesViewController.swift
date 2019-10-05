//
//  PassesViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/4/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase


//TODO: Fix timing
enum StudentPassStatus {
    case signedOut, signedIn
    
    func stringValue() -> String {
        switch self {
        case .signedOut:
            return "Signed Out"
        case .signedIn:
            return "Signed In"
        }
    }
}

struct StudentPassInfo {
    let name : String
    let graduationYear : Int
    let id : Int
    let currentStatus : (StudentPassStatus, Date)
    let previousStatuses : [(StudentPassStatus, Date)]
}

///Receives from Firebase, parses, and displays students out with passes
class PassesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak private var tableView: UITableView! { didSet {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
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
            for (_, student) in studentsDict where student["currentStatus"] as? String == "out" {
                let studentPassInfo = self.parseSignedOutStudentForPassInfo(student)
                self.signedOutStudentInfoArray.append(studentPassInfo)
            }
            self.tableView.reloadData()
        }
    }
    private func parseSignedOutStudentForPassInfo(_ student : [String:Any]) -> StudentPassInfo {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let studentLog = student["log"] as? [[String:String]]
        var logToStore = [(StudentPassStatus, Date)]()
        for logEntry in studentLog ?? [[String:String]]() {
            let oldStatus = (logEntry["status"]) == "out"
                ? StudentPassStatus.signedOut
                : StudentPassStatus.signedIn
            let oldDate = dateTimeFormatter.date(from: logEntry["time"]!)!
            let logToAdd = (oldStatus, oldDate)
            logToStore.append(logToAdd)
        }
        let timeString = student["timeOfStatusChange"] as! String
        let time = dateTimeFormatter.date(from: timeString)!
        return StudentPassInfo(
            name: student["name"] as! String,
            graduationYear: student["graduationYear"] as! Int,
            id: student["id"] as! Int,
            currentStatus: (.signedOut, time),
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
            
            passDetailVC.logToDisplay = signedOutStudentInfoArray[index].previousStatuses
            passDetailVC.titleToSet = signedOutStudentInfoArray[index].name
        }
    }
    
    
    
}
