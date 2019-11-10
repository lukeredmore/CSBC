//
//  PassDetailViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/4/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Shows past pass activity with data from parent VC (PassesViewController)

class PassDetailViewController: CSBCSearchViewController<StudentStatus, PassDetailTableViewCell> {
    
    let student : StudentPassInfo!
    
    
    init(forStudent student: StudentPassInfo) {
        self.student = student
        let configuration = CSBCSearchConfiguration(
            pageTitle: "",
            emptyDataMessage: "No log exists for this student",
            emptySearchMessage: "No entries found",
            xibIdentifier: "PassDetailTableViewCell",
            refreshConfiguration: .never,
            allowSelection: false,
            searchPlaceholder: student.name,
            backgroundButtonText: nil
        )
        super.init(configuration: configuration)
    
        let set = createSet(fromStudent: student)
        loadTable(withData: set)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func createSet(fromStudent student : StudentPassInfo) -> Set<StudentStatus> {
        let logToConvert : Set<StudentStatus> = [student.currentStatus]
        return logToConvert.union(Set(student.previousStatuses))
    }
        
}
