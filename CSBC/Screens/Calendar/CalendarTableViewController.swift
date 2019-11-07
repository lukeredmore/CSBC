//
//  CalendarTableViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 11/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import SafariServices

class CalendarTableViewController: CSBCSearchViewController<EventsModel, EventsTableViewCell> {
    
    private var storedSchoolsToShow = [true, true, true, true]
    private lazy var eventsRetriever = EventsRetriever(completion: loadTable)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        setEmptyDataMessage("There are currently no events scheduled", whileSearching: "No events found")
        setIdentifierForXIBDefinedCell("EventsTableViewCell")
        addFilterMenu()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        eventsRetriever.retrieveEventsArray()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 54))
        let button = UIButton(frame: footer.bounds)
        button.addTarget(self, action: #selector(viewMoreButtonPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        button.setTitleColor(.csbcAlwaysGray, for: .normal)
        button.setTitle("View More >", for: .normal)
        footer.addSubview(button)
        footer.backgroundColor = .csbcBackground
        tableView.tableFooterView = footer
    }
    
    override func refreshData() {
        super.refreshData()
        eventsRetriever.retrieveEventsArray(forceReturn: false, forceRefresh: true)
    }
    func addFilterMenu() {
        let dotsMenu = UIBarButtonItem(title: "•••", style: .plain, target: self, action: #selector(filterCalendarData))
        navigationItem.rightBarButtonItem = dotsMenu
    }
    @objc func filterCalendarData() {
        if loadingSymbol.isHidden {
            self.present(FilterCalendarViewController(currentlyShownSchools: storedSchoolsToShow, completion: userDidSelectSchools), animated: true)
        }
    }
    @objc func viewMoreButtonPressed() {
        if loadingSymbol.isHidden {
            if let url = URL(string: "https://csbcsaints.org/calendar/") {
                let safariView = SFSafariViewController(url: url)
                safariView.configureForCSBC()
                self.present(safariView, animated: true, completion: nil)
            }
        }
    }
    
    func userDidSelectSchools(schoolsToShow: [Bool]) {
        var filtersToSend = [String]()
        guard schoolsToShow != [true, true, true, true] else { super.filters = filtersToSend; return }
        storedSchoolsToShow = schoolsToShow
        for i in schoolsToShow.indices where schoolsToShow[i] {
            filtersToSend.append(shortSchoolsArray[i])
        }
        super.filters = filtersToSend
    }
}

