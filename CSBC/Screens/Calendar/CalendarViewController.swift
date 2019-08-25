//
//  CalendarViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import SafariServices

class CalendarViewController: CSBCViewController, UITableViewDataSource, DataEnteredDelegate  {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak private var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var searchBarContainerView: UIView!
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
        
        return refreshControl
    }()
    
    private var searchControllerController : CSBCSearchController!
    private var modelArrayForSearch : [EventsModel] {
        get {
            if searchControllerController.searchController.searchBar.text == "" && storedSchoolsToShow == [true, true, true, true] {
                return calendarData.eventsModelArray
            } else {
                return calendarData.eventsModelArrayFiltered
            }
        }
        set {
            calendarData.eventsModelArray = newValue
        }
    }
    
    private lazy var eventsRetriever = EventsRetriever(delegate: self, completion: setupCalendarTable)
    private(set) var eventsDataPresent = false
    private(set) var calendarData = EventsDataParser()
    private var storedSchoolsToShow : [Bool] = [true, true, true, true]

    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        searchControllerController = CSBCSearchController(searchBarContainerView: searchBarContainerView, searchBarTopConstraint: searchBarTopConstraint, athleticsParent: nil, eventsParent: self)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .csbcAccentGray
        searchBarTopConstraint.constant = -56
        loadingSymbol.startAnimating()
        tableView.isHidden = true
        eventsRetriever.retrieveEventsArray()
    }
    override func viewWillDisappear(_ animated: Bool) {
        view.backgroundColor = .csbcAccentGray
    }
    
    
    //MARK: Calendar data methods
    func userDidSelectSchools(schoolsToShow: [Bool]) {
        self.storedSchoolsToShow = schoolsToShow
        print("I'm supposed to show \(schoolsToShow)")
        searchControllerController.filterEventsRowsForSchoolsSelected(schoolsToShow)
        setupCalendarTable(eventsArray: modelArrayForSearch)
    }
    @objc private func refreshData() {
        eventsRetriever.retrieveEventsArray(forceReturn: false, forceRefresh: true)
    }
    private func setupCalendarTable(eventsArray: [EventsModel], keepExistingData shouldKeep : Bool = false) {
        if modelArrayForSearch != eventsArray {
            if shouldKeep {
                let eventsArrayAsSet = Set(calendarData.eventsModelArray).union(Set(eventsArray))
                modelArrayForSearch = eventsArrayAsSet.sorted()
            } else {
                modelArrayForSearch = eventsArray
            }
        }
        if eventsArray == [EventsModel]() {
            print("No data present in Calendar view")
            eventsDataPresent = false
            searchBarTopConstraint.constant = -56
        } else {
            print("Data present in Calendar view")
            eventsDataPresent = true
            searchBarTopConstraint.constant = 0
        }
        tableView.delegate = searchControllerController
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.reloadData()
        tableView.isHidden = false
        view.backgroundColor = .csbcNavBarBackground
        view.layoutIfNeeded()
        loadingSymbol.stopAnimating()
        refreshControl.endRefreshing()
    }
    @IBAction private func filterCalendarData(_ sender: Any) {
        if loadingSymbol.isHidden && eventsDataPresent {
            performSegue(withIdentifier: "CalendarSettingsSegue", sender: self)
        }
    }
    @IBAction func viewMoreButtonPressed(_ sender: Any) {
        if loadingSymbol.isHidden {
            if let url = URL(string: "https://csbcsaints.org/calendar/") {
                let safariView = SFSafariViewController(url: url)
                safariView.configureForCSBC()
                self.present(safariView, animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK: TableView Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArrayForSearch.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "calendarTableCell", for: indexPath) as? CalendarTableViewCell else { return UITableViewCell() }
        cell.addData(model: modelArrayForSearch[indexPath.row])
        return cell
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CalendarSettingsSegue" {
            let childVC = segue.destination as! FilterCalendarViewController
            childVC.delegate = self
            childVC.buttonStates = self.storedSchoolsToShow
        }
    }
}

class HalfSizePresentationController : UIPresentationController {
    private func frameOfPresentedViewInContainerView() -> CGRect {
        return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height/2)
    }
}


