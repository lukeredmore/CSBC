//
//  CalendarTableViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 11/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import SafariServices

///Displays events from EventsRetriever and receives filter event from FilterCalendarViewController
class CalendarTableViewController: CSBCSearchViewController<EventsModel, EventsTableViewCell> {
    
    private var storedSchoolsToShow = [true, true, true, true]
    private lazy var eventsRetriever = EventsRetriever(completion: loadTable)
    
    init() {
        let configuration = CSBCSearchConfiguration(
            pageTitle: "Calendar",
            emptyDataMessage: "There are currently no events scheduled",
            emptySearchMessage: "No events found",
            xibIdentifier: "EventsTableViewCell",
            refreshConfiguration: .whileNotSearching,
            allowSelection: .contextMenu,
            searchPlaceholder: "Search",
            backgroundButtonText: "View More >"
        )
        super.init(configuration: configuration)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFilterMenu()
    }
    override func viewWillAppear(_ animated: Bool) {
        eventsRetriever.retrieveEventsArray()
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
    override func backgroundButtonPressed() {
        super.backgroundButtonPressed()
        if let url = URL(string: "https://csbcsaints.org/calendar/") {
            let safariView = SFSafariViewController(url: url)
            safariView.configureForCSBC()
            self.present(safariView, animated: true, completion: nil)
        }
    }
    
    @available(iOS 13.0, *)
    override func createContextMenuActions(for model: EventsModel) -> [UIMenuElement] {
        let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) {
            action in
            let pasteboard = UIPasteboard.general
            pasteboard.string = model.event
        }
        
        let addToCalendar = UIAction(title: "Add to Calendar", image: UIImage(systemName: "calendar")) { action in
            
            EventsCalendarManager.presentCalendarModalToAddEvent(event: model) { (accessGranted) in
                guard !accessGranted else { return }
                let alert = UIAlertController(title: "Cannot access your Calendar", message: "Please enable in Settings", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
        }
        return [copy, addToCalendar]
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

