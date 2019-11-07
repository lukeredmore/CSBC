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
        super.init(nibName: nil, bundle: nil)
        self.title = student.name
        setEmptyDataMessage("No log exists for this student", whileSearching: "No entries found")
        setIdentifierForXIBDefinedCell("PassDetailTableViewCell")
        refreshConfiguration = .never
        super.searchPlaceholder = student.name
        let set = createSet(fromStudent: student)
        loadTable(withData: set)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSet(fromStudent student : StudentPassInfo) -> Set<StudentStatus> {
        let logToConvert : Set<StudentStatus> = [student.currentStatus]
        return logToConvert.union(Set(student.previousStatuses))
    }
        
}
