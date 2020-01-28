//
//  AllStudentPassesViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/23/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Displays all students in CSBC pass system regardless of status
class AllStudentPassesViewController: CSBCSearchViewController<AllStudentPassInfo, AllStudentsPassesTableViewCell> {
    private lazy var passesRetriever = PassesRetriever(completion: loadTable)

    init() {
        let configuration = CSBCSearchConfiguration(
            pageTitle: "All Students",
            emptyDataMessage: "There are currently no students in the Seton Pass System",
            emptySearchMessage: "No students found",
            xibIdentifier: "AllStudentsPassesTableViewCell",
            refreshConfiguration: .never,
            allowSelection: .selection,
            searchPlaceholder: "Search",
            backgroundButtonText: nil
        )
        super.init(configuration : configuration)
        passesRetriever.retrievePassesSet()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func cellSelected(withModel model: AllStudentPassInfo, forCell cell : AllStudentsPassesTableViewCell) {
        guard searchLoadingSymbol.isHidden else { return }
        self.present(PassDetailViewController(forStudent: model), animated: true)
    }
}
