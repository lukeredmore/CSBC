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

///Downloads athletics data, outsources parsing, then displays results in a UITableView. It outsources search functions, but can display the filtered (searched) data
class AthleticsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var loadingSymbol: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView! //.
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarContainerView: UIView!
    
    var athleticsData = AthleticsDataParser()
        
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.getAthleticsData), for: .valueChanged)
        refreshControl.tintColor = .gray
        return refreshControl
    }()
    var searchControllerController : CSBCSearchController!
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Athletics"
        loadingSymbol.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingSymbol.style = .large
        } else {
            loadingSymbol.style = .whiteLarge
            loadingSymbol.color = .gray
        }
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        searchControllerController = CSBCSearchController(searchBarContainerView: searchBarContainerView, searchBarTopConstraint: searchBarTopConstraint, athleticsParent: self, eventsParent: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        if athleticsData.athleticsModelArray.isEmpty {
            print("groupedArray is empty on viewWillAppear")
            tableView.isHidden = true
            loadingSymbol.startAnimating()
            searchBarTopConstraint.constant = -56
            view.layoutIfNeeded()
            getAthleticsData()
        } else {
            print("groupedArray has \(athleticsData.athleticsModelArray.count) values on viewWillAppear")
            setupTable()
        }
    }

    //MARK: Athletics Data Methods
    @objc func getAthleticsData() {
        print("we are asking for data")
        let parameters = ["game_types" : ["regular_season", "scrimmage", "post_season", "event"]]
        Alamofire.request("https://www.schedulegalaxy.com/api/v1/schools/163/activities", method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Athletics Data Received")
                let athleticsJSON : JSON = JSON(response.result.value!)
                self.athleticsData.parseAthleticsData(json: athleticsJSON)
                self.setupTable()
            }
        }
    }
    func setupTable() {
        tableView.dataSource = self
        tableView.delegate = searchControllerController
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.reloadData()
        searchBarTopConstraint.constant = 0
        view.layoutIfNeeded()
        tableView.isHidden = false
        loadingSymbol.stopAnimating()
        view.backgroundColor = .csbcGreen
        refreshControl.endRefreshing()
    }
    
    
    //MARK: TableView Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
            return athleticsData.athleticsModelArrayFiltered.count
        } else {
            return athleticsData.athleticsModelArray.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
            return athleticsData.athleticsModelArrayFiltered[section].sport.count
        } else {
            return athleticsData.athleticsModelArray[section].sport.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "athleticsTableCell", for: indexPath) as? AthleticsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AthleticsTableViewCell.")
        }
        let modelForCurrentCell : AthleticsModel
        if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
            modelForCurrentCell = athleticsData.athleticsModelArrayFiltered[indexPath.section]
        } else {
            modelForCurrentCell = athleticsData.athleticsModelArray[indexPath.section]
        }
        cell.addData(model: modelForCurrentCell, index: indexPath.row)
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
            return athleticsData.athleticsModelArrayFiltered[section].date
        } else {
            return athleticsData.athleticsModelArray[section].date
        }
    }
}


