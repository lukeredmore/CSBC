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
    
    init() {
        let configuration = CSBCSearchConfiguration(
            pageTitle: "Athletics",
            emptyDataMessage: "There are currently no athletic events scheduled",
            emptySearchMessage: "No events found",
            xibIdentifier: "AthleticsTableViewCell",
            refreshConfiguration: .whileNotSearching,
            allowSelection: .contextMenu,
            searchPlaceholder: "Search",
            backgroundButtonText: "Schedule Galaxy >"
        )
        super.init(configuration: configuration)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        athleticsRetriever.retrieveAthleticsArray()
    }
    
    override func refreshData() {
        super.refreshData()
        athleticsRetriever.retrieveAthleticsArray(forceReturn: false, forceRefresh: true)
    }
    
    override func backgroundButtonPressed() {
        super.backgroundButtonPressed()
        if let url = URL(string: "https://www.schedulegalaxy.com/schools/163") {
            let safariView = SFSafariViewController(url: url)
            safariView.configureForCSBC()
            self.present(safariView, animated: true, completion: nil)
        }
    }
    
    @available(iOS 13.0, *)
    override func createContextMenuActions(for model: AthleticsModel) -> [UIMenuElement] {
        let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) {
            action in
            let pasteboard = UIPasteboard.general
            pasteboard.string = model.toString()
        }
        
        let addToCalendar = UIAction(title: "Add to Calendar", image: UIImage(systemName: "calendar")) { action in
            
            AthleticsCalendarManager.presentCalendarModalToAddAthleticEvent(event: model) { (accessGranted) in
                guard !accessGranted else { return }
                let alert = UIAlertController(title: "Cannot access your Calendar", message: "Please enable in Settings", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
        }
        return [copy, addToCalendar]
    }
}
