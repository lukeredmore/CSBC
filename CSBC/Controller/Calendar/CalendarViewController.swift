//
//  CalendarViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import AuthenticationServices

class CalendarViewController: UIViewController, UITableViewDataSource, DataEnteredDelegate  {
    
    var calendarData = EventsParsing()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.getCalendarEvents), for: .valueChanged)
        refreshControl.tintColor = .gray
        
        return refreshControl
    }()
    var storedSchoolsToShow : [Bool] = []
    var searchController : UISearchController = UISearchController(searchResultsController: nil)
    var filteredEvents : [[String:String]] = [[:]]
    var eventsModelArray = [EventsModel]()
    var eventsModelArrrayFiltered = [EventsModel]()
    var showSearchBar = false

    @IBOutlet weak var loadingSymbol: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarContainerView: UIView!
    
    var searchControllerController : CSBCSearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        calendarData.storedSchoolsToShow = [true, true, true, true]
        loadingSymbol.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingSymbol.style = .large
        } else {
            loadingSymbol.style = .whiteLarge
            loadingSymbol.color = .gray
        }
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        searchControllerController = CSBCSearchController(searchBarContainerView: searchBarContainerView, searchBarTopConstraint: searchBarTopConstraint, athleticsParent: nil, eventsParent: self)

    }
    override func viewWillAppear(_ animated: Bool) {
        if calendarData.filteredEventArrayNoDuplicates.count < 2 { //events.isEmpty {
            print("filteredEventArrayNoDuplicates is empty on viewWillAppear")
            tableView.isHidden = true
            loadingSymbol.startAnimating()
            getCalendarEvents()
        } else {
            print("filteredEventArrayNoDuplicates has \(calendarData.filteredEventArrayNoDuplicates.count) values on viewWillAppear")
            setupCalendarTable()
        }
    }
    
    
    //MARK: Calendar data methods
    func userDidSelectSchools(schoolsToShow: [Bool]) {
        calendarData.storedSchoolsToShow = schoolsToShow
        print("I'm supposed to show \(calendarData.storedSchoolsToShow)")
        calendarData.userDidSelectSchools()
        setupCalendarTable()
    }
    @objc func getCalendarEvents() {
        Alamofire.request("https://csbcsaints.org/calendar").responseString(queue: nil, encoding: .utf8) { response in
            if let html = response.result.value {
                //let date = Date()
                //print("data received at \(date)")
                if html.contains("span") {
                    self.calendarData.parseHTMLForEvents(html: html)
                    //self.userDidSelectSchools(schoolsToShow: self.schoolsToShow)
                    self.setupCalendarTable()
                    
                }
            }
        }
    }
    func setupCalendarTable() {
        eventsModelArray.removeAll()
        for i in 0..<calendarData.filteredEventArrayNoDuplicates.count {
            let eventToAppend = EventsModel(
                date: calendarData.filteredEventArrayNoDuplicates[i]["date"]!,
                day: calendarData.filteredEventArrayNoDuplicates[i]["day"]!,
                month: calendarData.filteredEventArrayNoDuplicates[i]["month"]!,
                time: calendarData.filteredEventArrayNoDuplicates[i]["time"]!,
                event: calendarData.filteredEventArrayNoDuplicates[i]["event"]!,
                schools: calendarData.filteredEventArrayNoDuplicates[i]["schools"]!
            )
            eventsModelArray.append(eventToAppend)
        }
        tableView.delegate = searchControllerController
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.reloadData()
        tableView.isHidden = false
        showSearchBar = true
        searchBarTopConstraint.constant = 0
        view.layoutIfNeeded()
        loadingSymbol.stopAnimating()
        view.backgroundColor = .csbcGreen
        refreshControl.endRefreshing()
    }
    @IBAction func filterCalendarData(_ sender: Any) {
        if loadingSymbol.isHidden {
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
        if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
            return eventsModelArrrayFiltered.count
        } else {
            return eventsModelArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarTableCell", for: indexPath) as! CalendarTableViewCell
        if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
            cell.addData(model: eventsModelArrrayFiltered[indexPath.row])
        } else {
            cell.addData(model: eventsModelArray[indexPath.row])
        }
        return cell
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CalendarSettingsSegue" {
            let childVC = segue.destination as! FilterCalendarViewController
            childVC.delegate = self
            childVC.buttonStates = calendarData.storedSchoolsToShow
        }
    }
    
}

class HalfSizePresentationController : UIPresentationController {
    func frameOfPresentedViewInContainerView() -> CGRect {
        return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height/2)
    }
}


