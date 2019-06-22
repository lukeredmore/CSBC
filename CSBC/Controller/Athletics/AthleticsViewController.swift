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
    var rowHeight : [IndexPath : CGFloat] = [:]
    var numberOfDatesSum : [Int] = []
    //var groupedArray : [[[String:String]]] = [[[:]]]
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
    var athletics = [[AthleticsModel]]()
    var athleticsFilteredModel = [[AthleticsModel]]()
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
        
        //getAthleticsData(url: athleticsDataURL)
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
        
        athletics.removeAll()
        var gameToAppend : AthleticsModel
        var daysToAppend : [AthleticsModel] = [AthleticsModel]()
        for i in 0..<athleticsData.groupedArray.count {
            daysToAppend.removeAll()
            print(daysToAppend, " this here is days to append")
            for n in 0..<athleticsData.groupedArray[i].count {
                
                
                let consolidatedData = athleticsData.groupedArray[i][n]
                print(consolidatedData["date"], " is what the date is ")
                gameToAppend = AthleticsModel(
                    homeGame: consolidatedData["homeGame"]!,
                    gender: consolidatedData["gender"]!,
                    level: consolidatedData["level"]!,
                    sport: consolidatedData["sport"]!,
                    opponent: consolidatedData["opponent"]!,
                    time: consolidatedData["time"]!,
                    date: consolidatedData["date"]!
                )
                daysToAppend.append(gameToAppend)
                print(daysToAppend[0].date)
            }
            athletics.append(daysToAppend)
            print(athletics[0][0].date)
            
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
        athleticsFilteredModel.removeAll()
        for i in 0..<athletics.count {
            athleticsFilteredModel.append(athletics[i].filter({( model : AthleticsModel) -> Bool in
                return model.date.lowercased().contains(searchText.lowercased())||model.opponent.lowercased().contains(searchText.lowercased())||model.level.lowercased().contains(searchText.lowercased())||model.sport.lowercased().contains(searchText.lowercased())||model.gender.lowercased().contains(searchText.lowercased())
                
            }))
        }
        
        var i = athleticsFilteredModel.count - 1
        while i > -1 {
            if athleticsFilteredModel[i].isEmpty {
                athleticsFilteredModel.remove(at: i)
            }
            i -= 1
        }
        
        tableView.reloadData()
    }
    
    //MARK: Table stuff
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return athleticsFilteredModel.count
        } else {
            return athleticsData.groupedArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return athleticsFilteredModel[section].count
        } else {
            return athleticsData.groupedArray[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "athleticsTableCell", for: indexPath) as? AthleticsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AthleticsTableViewCell.")
        }
        if searchController.isActive && searchController.searchBar.text != "" {
            let model: AthleticsModel
            model = athleticsFilteredModel[indexPath.section][indexPath.row]//
            cell.titleLabel.text = "\(model.gender)'s \(model.sport) \(model.homeGame) \(model.opponent)"
            var textFrame = CGRect(x: 20, y: 20, width: 20, height: 20)
            textFrame = cell.titleLabel.textRect(forBounds: cell.titleLabel.frame, limitedToNumberOfLines: 2)
            rowHeight[indexPath] = textFrame.height
            cell.levelLabel.text = model.level
            cell.timeLabel.text = model.time
            
        } else {
            //        print("section is \(indexPath.section), row is \(indexPath.row), \(athleticsData.groupedArray[indexPath.section][indexPath.row]["gender"]!) isn't nil")
            //        print("section is \(indexPath.section), row is \(indexPath.row), \(athleticsData.groupedArray[indexPath.section][indexPath.row]["sport"]!) isn't nil")
            //        print("section is \(indexPath.section), row is \(indexPath.row), \(athleticsData.groupedArray[indexPath.section][indexPath.row]["homeGame"]!) isn't nil")
            //        print("section is \(indexPath.section), row is \(indexPath.row), \(athleticsData.groupedArray[indexPath.section][indexPath.row]["opponent"]!) isn't nil")
            //        print("section is \(indexPath.section), row is \(indexPath.row), \(athleticsData.groupedArray[indexPath.section][indexPath.row]["date"]!) isn't nil")
            cell.titleLabel.text = "\(athleticsData.groupedArray[indexPath.section][indexPath.row]["gender"]!)'s \(athleticsData.groupedArray[indexPath.section][indexPath.row]["sport"]!) \(athleticsData.groupedArray[indexPath.section][indexPath.row]["homeGame"]!) \(athleticsData.groupedArray[indexPath.section][indexPath.row]["opponent"]!)"//" on \(athleticsData.groupedArray[indexPath.section][indexPath.row]["date"]!)"
            var textFrame = CGRect(x: 20, y: 20, width: 20, height: 20)
            textFrame = cell.titleLabel.textRect(forBounds: cell.titleLabel.frame, limitedToNumberOfLines: 2)
            rowHeight[indexPath] = textFrame.height
            cell.levelLabel.text = athleticsData.groupedArray[indexPath.section][indexPath.row]["level"]
            cell.timeLabel.text = athleticsData.groupedArray[indexPath.section][indexPath.row]["time"]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return athleticsFilteredModel[section][0].date
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
        let font = UIFont(name: "Gotham-Bold", size: 18)
        header.textLabel?.font = font
        
    }
    
    
    //MARK: Refresh stuff
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //tableView.dataSource = nil
        
        if Reachability.isConnectedToNetwork(){
            firstTimeLoaded = false
            getAthleticsData(url: athleticsDataURL)
            tableView.reloadData()
            //refreshControl.endRefreshing()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        
        //print("Translation: \(translation.y)")
        //print(searchBarTopConstraint.constant)
        if translation.y > 0 && searchController.searchBar.text == "" && searchBarTopConstraint.constant != 0 && !searchController.isActive {//}&& searchBarTopConstraint.constant == -56 && showSearchBar {
            if translation.y < 56 {
                //print("bar should be growing")
                searchBarTopConstraint.constant = translation.y - 56 //show search bar
            } else if translation.y == 56 {
                //print("this runs every time 2?")
                searchBarTopConstraint.constant = 0
                //scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView.superview)
            }
            self.view.layoutIfNeeded()

        } else if translation.y < 0 && searchController.searchBar.text == "" && searchBarTopConstraint.constant != -56 && !searchController.isActive {//} && searchBarTopConstraint.constant == 0 && !searchController.isActive) || !showSearchBar) {
            if translation.y > -56 {
                //print("bar should be shrinking")
                searchBarTopConstraint.constant = translation.y //show search bar
            } else if translation.y == -56 {
                //print("this runs every time?")
                searchBarTopConstraint.constant = -56
                //scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView.superview)
            }
            self.view.layoutIfNeeded()
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print("no more touchy")
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
    

}


