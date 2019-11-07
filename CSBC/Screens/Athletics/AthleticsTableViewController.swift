//
//  AthleticsTableViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 11/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Displays athletic events from AthleticsRetriever
class AthleticsTableViewController: CSBCSearchViewController<AthleticsModel, AthleticsTableViewCell> {
    private lazy var athleticsRetriever = AthleticsRetriever(completion: loadTable)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Athletics"
        setEmptyDataMessage("There are currently no athletic events scheduled", whileSearching: "No events found")
        setIdentifierForXIBDefinedCell("AthleticsTableViewCell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        athleticsRetriever.retrieveAthleticsArray()
    }
    
    override func refreshData() {
        super.refreshData()
        athleticsRetriever.retrieveAthleticsArray(forceReturn: false, forceRefresh: true)
    }
}
