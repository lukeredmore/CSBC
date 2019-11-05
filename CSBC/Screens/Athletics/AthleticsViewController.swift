//
//  AthleticsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/19/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

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
    
    private lazy var athleticsRetriever = AthleticsRetriever(completion: setupTable)
    var athleticsDataPresent = false
    var athleticsData = AthleticsDataParser()
    
    private lazy var searchControllerController = CSBCSearchController(forVC: self, in: searchBarContainerView, with: searchBarTopConstraint, ofType: .athletics)
    private var dataToDisplay : [[AthleticsModel]] {
        get {
            if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
                return nestedFiltered
            } else {
                return nestedUnfiltered
//                return athleticsData.athleticsModelArray
            }
        }
        set {
            athleticsData.athleticsModelArray.removeAll()// = newValue
        }
    }
    private var nestedUnfiltered = [[AthleticsModel]]()
     private var nestedFiltered = [[AthleticsModel]]()
    
    func nestAthleticsSet(_ given : Set<AthleticsModel>) -> [[AthleticsModel]] {
        let arr = given.sorted()
        var dictToFlatten = [DateComponents : [AthleticsModel]]()
        for each in arr {
            if dictToFlatten[each.date] != nil {
                dictToFlatten[each.date]?.append(each)
            } else {
                dictToFlatten[each.date] = [each]
            }
        }
        dictToFlatten = dictToFlatten.mapValues { $0.sorted { $0.time < $1.time } }
        return Array(dictToFlatten.values).sorted { $0[0].date < $1[0].date }
    }
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Athletics"
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .csbcAccentGray
        searchBarTopConstraint.constant = -56
        loadingSymbol.startAnimating()
        tableView.isHidden = true
//        view.layoutIfNeeded()
        athleticsRetriever.retrieveAthleticsArray()
    }
    override func viewWillDisappear(_ animated: Bool) {
        view.backgroundColor = .csbcAccentGray
    }

    //MARK: Athletics Data Methods
    @objc private func refreshData() {
        athleticsRetriever.retrieveAthleticsArray(forceReturn: false, forceRefresh: true)
    }
    private func setupTable(athleticsArray : Set<AthleticsModel>) {
        nestedUnfiltered = nestAthleticsSet(athleticsArray)
        if athleticsArray == Set<AthleticsModel>() {
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
    
    
    //MARK: TableView Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataToDisplay.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataToDisplay[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "athleticsTableCell", for: indexPath) as?  AthleticsTableViewCell else { return UITableViewCell() }
        cell.addData(model: dataToDisplay[indexPath.section][indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let date = Calendar.current.date(from: dataToDisplay[section][0].date) else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: date)
    }
}


