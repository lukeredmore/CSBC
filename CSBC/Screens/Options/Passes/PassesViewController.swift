//
//  PassesViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/4/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase


/// Displays students out with passes
class PassesViewController : CSBCSearchViewController<SignedOutStudentPassInfo, PassTableViewCell> {
    private lazy var passesRetriever = PassesRetriever(completion: loadTable)
    private var clockTimer : Timer?
    
    init() {
        let configuration = CSBCSearchConfiguration(
            pageTitle: "Active Passes",
            emptyDataMessage: "There are no students out at this time",
            emptySearchMessage: "No signed out students found",
            xibIdentifier: "PassTableViewCell",
            refreshConfiguration: .never,
            allowSelection: .selection,
            searchPlaceholder: "Search",
            backgroundButtonText: "View All Students >"
        )
        super.init(configuration: configuration)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        passesRetriever.retrievePassesSet()
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tableView.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        clockTimer?.invalidate()
    }
    
    override func cellSelected(withModel student : SignedOutStudentPassInfo, forCell cell: PassTableViewCell) {
        present(PassDetailViewController(forStudent: student), animated: true)
    }
    
    override func backgroundButtonPressed() {
        super.backgroundButtonPressed()
        navigationController?.pushViewController(AllStudentPassesViewController(), animated: true)
    }
    
}
