//
//  TodayViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Programmatically creates today view controller with table view. Doesn't touch the data, except to send it through to the datasource
class TodayViewController: UIViewController {
    var headerLabel : UILabel!
    var headerView : UIView!
    var tableView : UITableView!
    
    var dateShown : String!
    var todaysEvents : [EventsModel] = []
    var todaysAthletics : AthleticsModel? = nil
    var forSchool : String!
    var dayOfCycle : Int!
    
    let customDataSource = TodayDataSource()
    var dayOfCycleText : String {
        if dayOfCycle != 0 {
            return "Today is Day \(dayOfCycle!)"
        } else {
            return "There is no school today"
        }
    }
    
    
    //MARK: Init Methods
    init(forDate : String, forSchool : String, forDayOfCycle : Int, athletics : AthleticsModel?, events : [EventsModel]) {
        self.dateShown = forDate
        self.todaysAthletics = athletics
        self.todaysEvents = events
        self.forSchool = forSchool
        self.dayOfCycle = forDayOfCycle
        super.init(nibName: nil, bundle: nil)
        
        createHeaderLabel()
        createHeaderView()
        createTableView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Interface Building Methods
    func createHeaderLabel() {
        headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 43))
        headerLabel.font = UIFont(name: "Gotham-Bold", size: 39)
        headerLabel.text = dayOfCycleText
        headerLabel.numberOfLines = 0
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.minimumScaleFactor = 0.5
        headerLabel.textColor = UIColor(named: "CSBCDarkText")
        headerLabel.textAlignment = .center
        headerLabel.frame = CGRect(x: headerLabel.frame.minX + 10, y: headerLabel.frame.minY + 12, width: UIScreen.main.bounds.width - 20, height: 43)
    }
    func createHeaderView() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        headerView.backgroundColor = .clear
        headerView.addSubview(headerLabel)
    }
    func createTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "TodayViewCell", bundle: nil), forCellReuseIdentifier: "todayViewCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        customDataSource.todaysAthletics = self.todaysAthletics
        customDataSource.todaysEvents = self.todaysEvents
        tableView.dataSource = customDataSource
        tableView.reloadData()
        print("TableView loaded")
    }
}
