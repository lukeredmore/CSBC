//
//  AthleticsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/19/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AthleticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    var athleticsData = AthleticsData()
    let athleticsDataURL = "https://www.schedulegalaxy.com/api/v1/schools/163/activities"
    let teamAbbreviations = ["V":"Varsity","JV":"JV","7/8TH":"Modified"]
    var gameInfo : [String : String] = [:]
    var gameInfoArray : [[String : String]] = [[:]]
    var gameDates : [String?] = []
    var numberOfDates : [String:Int] = [:]
    var numberOfDatesArray : [Int] = []
    var numberOfDatesSum : [Int] = []
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(AthleticsViewController.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .gray
        return refreshControl
    }()
    var firstTimeLoaded = true
    var searchController : UISearchController!
    let requestingURL = true
    var athleticsModelArray = [[AthleticsModel]]()
    var athleticsModelArrayFiltered = [[AthleticsModel]]()
    var showSearchBar = false
    
    private var originalTableViewOffset: CGFloat = 0
    
    @IBOutlet weak var loadingSymbol: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView! //.
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarContainerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Athletics"
        firstTimeLoaded = true
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
        if athleticsData.groupedArray.count < 2 {
            print("groupedArray is empty on viewWillAppear")
        } else {
            print("groupedArray has \(athleticsData.groupedArray.count) values on viewWillAppear")
        }
        if athleticsData.groupedArray == [[[:]]] {
            tableView.isHidden = true
            loadingSymbol.startAnimating()
            showSearchBar = false
            searchBarTopConstraint.constant = -56
            view.layoutIfNeeded()
            getAthleticsData(url: athleticsDataURL)
        } else {
            setupTable()
        }
    }

    //MARK: Athletics Data Methods
    func getAthleticsData(url: String) {
        print("we are asking for data")
        let parameters = ["game_types" : ["regular_season", "scrimmage", "post_season", "event"]]
        if requestingURL == true {
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
                response in
                if response.result.isSuccess {
                    print("Athletics Data Received")
                    let athleticsJSON : JSON = JSON(response.result.value!)
                    self.athleticsData.parseAthleticsData(json: athleticsJSON)
                    self.setupTable()
                }
            }
        } else {
            let path = Bundle.main.path(forResource: "testJSON", ofType: "json")!
            let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let athleticsJSON = JSON(parseJSON: jsonString!)
            athleticsData.parseAthleticsData(json: athleticsJSON)
            setupTable()
        }
        
    }
    func setupTable() {
        athleticsModelArray.removeAll()
        var gameToAppend : AthleticsModel
        var daysToAppend : [AthleticsModel] = [AthleticsModel]()
        for dateWithEvents in athleticsData.groupedArray {
            daysToAppend.removeAll()
            for event in dateWithEvents {
                gameToAppend = AthleticsModel(
                    homeGame: event["homeGame"]!,
                    gender: event["gender"]!,
                    level: event["level"]!,
                    sport: event["sport"]!,
                    opponent: event["opponent"]!,
                    time: event["time"]!,
                    date: event["date"]!
                )
                daysToAppend.append(gameToAppend)
            }
            athleticsModelArray.append(daysToAppend)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.reloadData()
        showSearchBar = true
        searchBarTopConstraint.constant = 0
        view.layoutIfNeeded()
        tableView.isHidden = false
        loadingSymbol.stopAnimating()
        view.backgroundColor = .csbcGreen
        refreshControl.endRefreshing()
    }
    
    
    //MARK: Search Methods
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
    func filterRowsForSearchedText(_ searchText: String) {
        athleticsModelArrayFiltered.removeAll()
        for i in 0..<athleticsModelArray.count {
            athleticsModelArrayFiltered.append(athleticsModelArray[i].filter({( model : AthleticsModel) -> Bool in
                return model.date.lowercased().contains(searchText.lowercased())||model.opponent.lowercased().contains(searchText.lowercased())||model.level.lowercased().contains(searchText.lowercased())||model.sport.lowercased().contains(searchText.lowercased())||model.gender.lowercased().contains(searchText.lowercased())
            }))
        }
        var i = athleticsModelArrayFiltered.count - 1
        while i > -1 {
            if athleticsModelArrayFiltered[i].isEmpty {
                athleticsModelArrayFiltered.remove(at: i)
            }
            i -= 1
        }
        tableView.reloadData()
    }
    
    
    //MARK: TableView and ScrollView Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return athleticsModelArrayFiltered.count
        } else {
            return athleticsModelArray.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return athleticsModelArrayFiltered[section].count
        } else {
            return athleticsModelArray[section].count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "athleticsTableCell", for: indexPath) as? AthleticsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AthleticsTableViewCell.")
        }
        let modelForCurrentCell : AthleticsModel
        if searchController.isActive && searchController.searchBar.text != "" {
            modelForCurrentCell = athleticsModelArrayFiltered[indexPath.section][indexPath.row]
        } else {
            modelForCurrentCell = athleticsModelArray[indexPath.section][indexPath.row]
        }
        cell.addData(model: modelForCurrentCell)
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return athleticsModelArrayFiltered[section][0].date
        } else {
            return athleticsData.groupedArray[section][0]["date"]
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Gotham-Bold", size: 18)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0 && searchController.searchBar.text == "" && searchBarTopConstraint.constant != 0 && !searchController.isActive { //scroll up
            if translation.y < 56 {
                searchBarTopConstraint.constant = translation.y - 56 //show search bar growing
            } else if translation.y == 56 {
                searchBarTopConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        } else if translation.y < 0 && searchController.searchBar.text == "" && searchBarTopConstraint.constant != -56 && !searchController.isActive { //scroll down
            if translation.y > -56 {
                searchBarTopConstraint.constant = translation.y //show search bar shrinking
            } else if translation.y == -56 {
                searchBarTopConstraint.constant = -56
            }
            self.view.layoutIfNeeded()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView.superview)
        if searchBarTopConstraint.constant < -45 {
            searchBarTopConstraint.constant = -56
        } else {
            searchBarTopConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    //MARK: Refresh Control
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //tableView.dataSource = nil
        if Reachability.isConnectedToNetwork(){
            firstTimeLoaded = false
            getAthleticsData(url: athleticsDataURL)
            tableView.reloadData()
            //refreshControl.endRefreshing()
        }
    }
}


