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

class CalendarViewController: CSBCViewController, UITableViewDataSource, DataEnteredDelegate  {
    
    var calendarData = EventsDataParser()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.getCalendarEvents), for: .valueChanged)
        refreshControl.tintColor = .gray
        
        return refreshControl
    }()
    var storedSchoolsToShow : [Bool] = [true, true, true, true]
    var searchController : UISearchController = UISearchController(searchResultsController: nil)
    var modelArrayForSearch : [EventsModel] {
        if /*!searchControllerController.searchController.isActive &&*/ searchControllerController.searchController.searchBar.text == "" && storedSchoolsToShow == [true, true, true, true] {
            print("\nI'm showing the full version\n")
            return calendarData.eventsModelArray
        } else {
            print("\nI'm showing the filtered version\n")
            return calendarData.eventsModelArrayFiltered
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarContainerView: UIView!
    
    var searchControllerController : CSBCSearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        searchControllerController = CSBCSearchController(searchBarContainerView: searchBarContainerView, searchBarTopConstraint: searchBarTopConstraint, athleticsParent: nil, eventsParent: self)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = UIColor(named: "CSBCAccentGray")
        if calendarData.eventsModelArray.count < 2 { //events.isEmpty {
            print("eventsModelArray is empty on viewWillAppear")
            tableView.isHidden = true
            loadingSymbol.startAnimating()
            getCalendarEvents()
        } else {
            print("eventsModelArray has \(calendarData.eventsModelArray.count) values on viewWillAppear")
            setupCalendarTable()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        view.backgroundColor = UIColor(named: "CSBCAccentGray")
    }
    
    
    //MARK: Calendar data methods
    func userDidSelectSchools(schoolsToShow: [Bool]) {
        self.storedSchoolsToShow = schoolsToShow
        print("I'm supposed to show \(schoolsToShow)")
        searchControllerController.filterEventsRowsForSchoolsSelected(schoolsToShow)
        setupCalendarTable()
    }
    @objc func getCalendarEvents() {
        Alamofire.request("https://csbcsaints.org/calendar").responseString(queue: nil, encoding: .utf8) { response in
            if let html = response.result.value {
                if html.contains("span") {
                    self.calendarData.parseHTMLForEvents(html: html)
                    self.setupCalendarTable()
                }
            }
        }
    }
    func setupCalendarTable() {
        tableView.delegate = searchControllerController
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.reloadData()
        tableView.isHidden = false
        view.backgroundColor = UIColor(named: "CSBCNavBarBackground")
        searchBarTopConstraint.constant = 0
        view.layoutIfNeeded()
        loadingSymbol.stopAnimating()
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
    func frameOfPresentedViewInContainerView() -> CGRect {
        return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height/2)
    }
}


