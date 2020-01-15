//
//  TableLocationViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 1/11/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class TableLocationViewController: CSBCSearchViewController<STEMTableModel, STEMTableCell> {
    private lazy var stemRetriever = STEMRetriever(completion: loadTable)
    
    init() {
        let configuration = CSBCSearchConfiguration(
            pageTitle: "STEM Night",
            emptyDataMessage: "No tables found",
            emptySearchMessage: "No tables found",
            xibIdentifier: "STEMTableCell",
            refreshConfiguration: .never,
            allowSelection: .selection,
            searchPlaceholder: "Search",
            backgroundButtonText: nil
        )
        super.init(configuration: configuration)
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stemRetriever.retrieveSTEMArray()
        tableView.reloadData()
    }
    
    override func cellSelected(withModel student : STEMTableModel, forCell cell : STEMTableCell) {
        let vc = STEMInfoViewController(for: student) {
            self.stemRetriever.toggle(for: student)
        }
        present(vc, animated: true)
    }
}
