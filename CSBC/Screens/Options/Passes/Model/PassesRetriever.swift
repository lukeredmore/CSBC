//
//  PassesRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 11/10/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Firebase

/// Returns CSBC pass info to caller
class PassesRetriever {
    private var signedOutStudentCompletion : ((Set<SignedOutStudentPassInfo>, Bool) -> Void)?
    private var allStudentCompletion : ((Set<AllStudentPassInfo>, Bool) -> Void)?
    private let passDataReference = Database.database().reference().child("PassSystem/Students")
    
    init(completion: @escaping (Set<AllStudentPassInfo>, Bool) -> Void) {
        self.allStudentCompletion = completion
    }
    init(completion: @escaping (Set<SignedOutStudentPassInfo>, Bool) -> Void) {
        self.signedOutStudentCompletion = completion
    }
    deinit {
        passDataReference.removeAllObservers()
    }
    
    func retrievePassesSet() {
        //Calculate grade level map
        let seniorsGradYear = Calendar.current.component(.year, from: DaySchedule.endDate)
        var gradeLevelMap = [seniorsGradYear : 12]
        for i in stride(from: seniorsGradYear + 1, to: seniorsGradYear + 6, by: 1) {
            gradeLevelMap[i] = gradeLevelMap[i - 1]! - 1
        }
        
        passDataReference.observe(.value) { (snapshot) in
            guard let studentsDict = snapshot.value as? [String:[String:Any]] else { return }
            
            if let completion = self.allStudentCompletion {
                var setToReturn = Set<AllStudentPassInfo>()
                for (_, student) in studentsDict {
                    guard let fullStudentPassInfo = self.parseStudentForPassInfo(student, gradeLevelMap: gradeLevelMap) else { continue }
                    setToReturn.insert(fullStudentPassInfo)
                }
                completion(setToReturn, false)
                
            } else if let completion = self.signedOutStudentCompletion {
                var setToReturn = Set<SignedOutStudentPassInfo>()
                for (_, student) in studentsDict {
                    guard let fullStudentPassInfo = self.parseStudentForPassInfo(student, gradeLevelMap: gradeLevelMap) else { continue }
                    guard let signedOutStudentInfo = self.parseSignedOutStudentForPassInfo(fullStudentPassInfo) else { continue }
                    setToReturn.insert(signedOutStudentInfo)
                }
                completion(setToReturn, false)
            }
        }
    }
    private func parseStudentForPassInfo(_ student : [String:Any], gradeLevelMap : [Int : Int]) -> AllStudentPassInfo? {
        let dateTimeFormatter = ISO8601DateFormatter()
        dateTimeFormatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        
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
        
        
        return AllStudentPassInfo(
            name: studentName,
            gradeLevel: studentGrade,
            currentStatus: currentStatus,
            previousStatuses: previousStatuses)
    }
    private func parseSignedOutStudentForPassInfo(_ student : AllStudentPassInfo) -> SignedOutStudentPassInfo? {
        
//        let statusArray = student.currentStatus.location.components(separatedBy: " - ")
        guard student.currentStatus.location.lowercased().contains("out") else { return nil }
        return SignedOutStudentPassInfo(
            name: student.name,
            gradeLevel: student.gradeLevel,
            currentStatus: student.currentStatus,
            previousStatuses: student.previousStatuses,
            location: student.currentStatus.location,
            time: student.currentStatus.time)
    }
}
