//
//  AllStudentPassesViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/23/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit


class AllStudentPassesViewController: CSBCSearchViewController<StudentPassInfo, AllStudentsPassesTableViewCell> {

    init(data: Set<StudentPassInfo>) {
        super.init(nibName: nil, bundle: nil)
        self.title = "All Students"
        setEmptyDataMessage("There are currently no students in the Seton Pass System", whileSearching: "No students found")
        setIdentifierForXIBDefinedCell("AllStudentsPassesTableViewCell")
        refreshConfiguration = .never
        loadTable(withData: data)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
