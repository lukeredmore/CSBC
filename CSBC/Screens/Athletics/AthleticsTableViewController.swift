//
//  AthleticsTableViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 11/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import SafariServices

///Displays athletic events from AthleticsRetriever
class AthleticsTableViewController: CSBCSearchViewController<AthleticsModel, AthleticsTableViewCell> {
    private lazy var athleticsRetriever = AthleticsRetriever(completion: loadTable)
    
    static let configuration = CSBCSearchConfiguration(
        pageTitle: "Athletics",
        emptyDataMessage: "There are currently no athletic events scheduled",
        emptySearchMessage: "No events found",
        xibIdentifier: "AthleticsTableViewCell",
        refreshConfiguration: .whileNotSearching,
        allowSelection: false,
        searchPlaceholder: "Search",
        backgroundButtonText: "Schedule Galaxy >"
    )
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 54))
        let button = UIButton(frame: footer.bounds)
        button.addTarget(self, action: #selector(backgroundButtonPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        button.setTitleColor(.csbcAlwaysGray, for: .normal)
        button.setTitle("Schedule Galaxy >", for: .normal)
        footer.addSubview(button)
        footer.backgroundColor = .csbcBackground
        tableView.tableFooterView = footer
    }
    override func viewWillAppear(_ animated: Bool) {
        athleticsRetriever.retrieveAthleticsArray()
    }
    
    override func refreshData() {
        super.refreshData()
        athleticsRetriever.retrieveAthleticsArray(forceReturn: false, forceRefresh: true)
    }
    
    override func backgroundButtonPressed(_ sender: UIButton) {
        super.backgroundButtonPressed(sender)
        if let url = URL(string: "https://www.schedulegalaxy.com/schools/163") {
            let safariView = SFSafariViewController(url: url)
            safariView.configureForCSBC()
            self.present(safariView, animated: true, completion: nil)
        }
    }
}
