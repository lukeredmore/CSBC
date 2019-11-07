//
//  PassesViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/4/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase


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
            
            //Calculate grade level map
            let seniorsGradYear = Calendar.current.component(.year, from: DaySchedule.endDate)
            var gradeLevelMap = [seniorsGradYear : 12]
            for i in stride(from: seniorsGradYear + 1, to: seniorsGradYear + 6, by: 1) {
                gradeLevelMap[i] = gradeLevelMap[i - 1]! - 1
            }
            
            
            for (_, student) in studentsDict {
                guard let studentPassInfo = self.parseStudentForPassInfo(student, gradeLevelMap: gradeLevelMap) else { continue }
                self.allStudentInfoArray.append(studentPassInfo)
                if studentPassInfo.currentStatus.location.lowercased().contains("out") {
                    self.signedOutStudentInfoArray.append(studentPassInfo)
                }
            }
        }
    }
    private func parseStudentForPassInfo(_ student : [String:Any], gradeLevelMap : [Int : Int]) -> StudentPassInfo? {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        
        guard let studentName = student["name"] as? String,
            let studentGraduationYear = student["graduationYear"] as? Int,
            let studentGrade = gradeLevelMap[studentGraduationYear],
            let currentLocation = student["currentStatus"] as? String,
            let timeOfStatusChangeString = student["timeOfStatusChange"] as? String,
            let timeOfStatusChange = dateTimeFormatter.date(from: timeOfStatusChangeString) else { return nil }
        
        let currentStatus = StudentStatus(location: currentLocation, time: timeOfStatusChange)
        var previousStatuses = [StudentStatus]()
        if let studentLog = student["log"] as? [[String:String]] {
            for logEntry in studentLog {
            guard let statusFromLog = logEntry["status"],
                let dateStringFromLog = logEntry["time"],
                let dateFromLog = dateTimeFormatter.date(from: dateStringFromLog)
                else { continue }
                previousStatuses.append(StudentStatus(location: statusFromLog, time: dateFromLog))
            }
        }
        
        
        return StudentPassInfo(
            name: studentName,
            gradeLevel: studentGrade,
            currentStatus: currentStatus,
            previousStatuses: previousStatuses)
    }
    
    @IBAction func viewMoreButtonPressed(_ sender: UIButton) {
        navigationController?.pushViewController(AllStudentPassesViewController(data: Set(allStudentInfoArray)), animated: true)
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

        cell.nameLabel.text = student.name + " (\(student.gradeLevel))"
        cell.locationLabel.text = student.currentStatus.location
        
        let interval = Date().timeIntervalSince(student.currentStatus.time)
        let timeString = interval.stringFromTimeInterval()
        cell.timeLabel.text = timeString
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = signedOutStudentInfoArray[indexPath.row]
        self.present(PassDetailViewController(forStudent: student), animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
