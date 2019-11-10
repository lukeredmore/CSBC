//
//  AllStudentPassesViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/23/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Displays all students in CSBC pass system regardless of status
class AllStudentPassesViewController: CSBCSearchViewController<StudentPassInfo, AllStudentsPassesTableViewCell> {
    
    static let configuration = CSBCSearchConfiguration(
        pageTitle: "All Students",
        emptyDataMessage: "There are currently no students in the Seton Pass System",
        emptySearchMessage: "No students found",
        xibIdentifier: "AllStudentsPassesTableViewCell",
        refreshConfiguration: .never,
        allowSelection: true,
        searchPlaceholder: "Search",
        backgroundButtonText: nil
    )

    init(data: Set<StudentPassInfo>) {
        super.init(configuration : AllStudentPassesViewController.configuration)
        loadTable(withData: data)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func cellSelected(withModel model: StudentPassInfo) {
        self.present(PassDetailViewController(forStudent: model), animated: true)
    }
}
