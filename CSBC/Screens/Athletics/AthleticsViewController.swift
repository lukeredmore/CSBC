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
class AthleticsViewController: CSBCViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak private var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var searchBarContainerView: UIView!
    @IBOutlet weak private var footerLabel: UILabel!
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
        
        return refreshControl
    }()
    var athleticsDataPresent = false
    var athleticsData = AthleticsDataParser()
    private var searchControllerController : CSBCSearchController!
    private var modelArrayForSearch : [AthleticsModel?] {
        get {
            if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
                return athleticsData.athleticsModelArrayFiltered
            } else {
                return athleticsData.athleticsModelArray
            }
        }
        set {
            athleticsData.athleticsModelArray = newValue
        }
    }
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Athletics"
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        searchControllerController = CSBCSearchController(searchBarContainerView: searchBarContainerView, searchBarTopConstraint: searchBarTopConstraint, athleticsParent: self, eventsParent: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = UIColor(named: "CSBCAccentGray")
        searchBarTopConstraint.constant = -56
        loadingSymbol.startAnimating()
        tableView.isHidden = true
        view.layoutIfNeeded()
        AthleticsRetriever().retrieveAthleticsArray(completion: setupTable)
    }
    override func viewWillDisappear(_ animated: Bool) {
        view.backgroundColor = UIColor(named: "CSBCAccentGray")
    }

    //MARK: Athletics Data Methods
    @objc private func refreshData() {
        AthleticsRetriever().retrieveAthleticsArray(forceReturn: false, forceRefresh: true, completion: setupTable)
    }
    private func setupTable(athleticsArray : [AthleticsModel?]) {
        if modelArrayForSearch != athleticsArray {
            modelArrayForSearch = athleticsArray
        }
        if athleticsArray == [AthleticsModel]() {
            print("No data present in Athletics view")
            athleticsDataPresent = false
            searchBarTopConstraint.constant = -56
            footerLabel.text = "No events found"
        } else {
            print("Data present in Athletics view")
            athleticsDataPresent = true
            searchBarTopConstraint.constant = 0
            footerLabel.text = ""
        }
        tableView.dataSource = self
        tableView.delegate = searchControllerController
        tableView.refreshControl = refreshControl
        tableView.reloadData()
        view.backgroundColor = UIColor(named: "CSBCNavBarBackground")
        tableView.isHidden = false
        view.layoutIfNeeded()
        loadingSymbol.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    
    //MARK: TableView Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return modelArrayForSearch.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rowCountModel = modelArrayForSearch[section] else { return 0 }
        return rowCountModel.title.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "athleticsTableCell", for: indexPath) as?  AthleticsTableViewCell else { return UITableViewCell() }
        if let model = modelArrayForSearch[indexPath.section] {
            cell.addData(model: model, index: indexPath.row)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let titleHeaderModel = modelArrayForSearch[section] else { return "" }
        return titleHeaderModel.date
    }
}


