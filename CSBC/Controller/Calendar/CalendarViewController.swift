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

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataEnteredDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    
    var calendarData = EventsParsing()
    var firstTimeLoaded = true
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(AthleticsViewController.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .gray
        
        return refreshControl
    }()
    var arrayToDisplay : [[String:String]] = [[:]]
    var storedSchoolsToShow : [Bool] = []
    var searchController : UISearchController!
    var filteredEvents : [[String:String]] = [[:]]
    var eventsModelArray = [EventsModel]()
    var eventsModelArrrayFiltered = [EventsModel]()
    var showSearchBar = false

    @IBOutlet weak var loadingSymbol: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarContainerView: UIView!
    
    
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
        
        setupSearchController()

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
    
    func userDidSelectSchools(schoolsToShow: [Bool]) {
        calendarData.storedSchoolsToShow = schoolsToShow
        print("I'm supposed to show \(calendarData.storedSchoolsToShow)")
        calendarData.userDidSelectSchools()
        setupCalendarTable()
    }
    
    func getCalendarEvents() {
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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //tableView.dataSource = nil
        
        if Reachability.isConnectedToNetwork(){
            firstTimeLoaded = false
            getCalendarEvents()
            tableView.reloadData()
            //refreshControl.endRefreshing()
        }
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
                safariView.preferredBarTintColor = .csbcGreenForSafariViewController
                safariView.preferredControlTintColor = .white
                safariView.modalTransitionStyle = .coverVertical
                safariView.modalPresentationStyle = .overFullScreen
                
                self.present(safariView, animated: true, completion: nil)
            }
        }
    }
    
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        
        //tableView.tableHeaderView = searchController.searchBar
        searchBarContainerView.addSubview(searchController.searchBar)
        searchBarContainerView.bringSubviewToFront(searchController.searchBar)
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.barTintColor = .csbcGreen
        searchController.searchBar.searchField.clearButtonMode = .always
        searchController.searchBar.searchField.backgroundColor = .csbcLightGreen
        searchController.searchBar.searchField.textColor = .white
        searchController.searchBar.searchField.attributedPlaceholder = NSAttributedString(
            string: searchController.searchBar.searchField.placeholder ?? "",
            attributes: [
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]
        )
        if let leftView = searchController.searchBar.searchField.leftView as? UIImageView {
            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
            leftView.tintColor = UIColor.white
        }
        
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.clipsToBounds = true
        searchController.searchBar.placeholder = "Search"
        definesPresentationContext = true
        //view.layoutIfNeeded()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let term = searchController.searchBar.text {
            filterRowsForSearchedText(term)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return eventsModelArrrayFiltered.count
        } else {
            return eventsModelArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarTableCell", for: indexPath) as! CalendarTableViewCell
        let model: EventsModel
        if searchController.isActive && searchController.searchBar.text != "" {
            model = eventsModelArrrayFiltered[indexPath.row]
        } else {
            model = eventsModelArray[indexPath.row]
        }
        cell.addData(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model: EventsModel
        if searchController.isActive && searchController.searchBar.text != "" {
            model = eventsModelArrrayFiltered[indexPath.row]
        } else {
            model = eventsModelArray[indexPath.row]
        }
        if indexPath.row == 0 && model.event == "" {
            return 0.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
//        if translation.y > 0 {
//            // swipes from top to bottom of screen -> down
//        } else {
//            // swipes from bottom to top of screen -> up
//        }
//    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CalendarSettingsSegue" {
            let childVC = segue.destination as! FilterCalendarViewController
            childVC.delegate = self
            childVC.buttonStates = calendarData.storedSchoolsToShow
        }
    }
    func filterRowsForSearchedText(_ searchText: String) {
        eventsModelArrrayFiltered.removeAll()
        eventsModelArrrayFiltered = eventsModelArray.filter({( model : EventsModel) -> Bool in
            return model.date.lowercased().contains(searchText.lowercased())||model.event.lowercased().contains(searchText.lowercased())||model.schools.lowercased().contains(searchText.lowercased())
            
        })
        tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0 && searchController.searchBar.text == "" && searchBarTopConstraint.constant != 0 && !searchController.isActive {//}&& searchBarTopConstraint.constant == -56 && showSearchBar {
            if translation.y < 56 {
                searchBarTopConstraint.constant = translation.y - 56 //show search bar
            } else if translation.y == 56 {
                searchBarTopConstraint.constant = 0
                //scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView.superview)
            }
            self.view.layoutIfNeeded()
            
        } else if translation.y < 0 && searchController.searchBar.text == "" && searchBarTopConstraint.constant != -56 && !searchController.isActive {//} && searchBarTopConstraint.constant == 0 && !searchController.isActive) || !showSearchBar) {
            if translation.y > -56 {
                searchBarTopConstraint.constant = translation.y //show search bar
            } else if translation.y == -56 {
                searchBarTopConstraint.constant = -56
                //scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView.superview)
            }
            self.view.layoutIfNeeded()
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print("no more touchy")
        scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView.superview)
        if searchBarTopConstraint.constant < -28 {
            searchBarTopConstraint.constant = -56
        } else {
            searchBarTopConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
            
        })
    }
}

class HalfSizePresentationController : UIPresentationController {
    func frameOfPresentedViewInContainerView() -> CGRect {
        return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height/2)
    }
}


