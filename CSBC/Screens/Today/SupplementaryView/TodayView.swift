//
//  TodayView.swift
//  CSBC
//
//  Created by Luke Redmore on 8/7/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit


//Create view programatically for TodayViewController
class TodayView: UIView {
    private var headerLabel : UILabel!
    private var headerView : UIView!
    var tableView : UITableView!
    private let dayOfCycle : Int!
    
    private var dayOfCycleText : String {
        if dayOfCycle > 0 && dayOfCycle < 7 {
            return "Today is Day \(dayOfCycle!)"
        } else {
            return "There is no school today"
        }
    }
    
    init(forDay day : Int) {
        self.dayOfCycle = day
        super.init(frame: CGRect.zero)
        createHeaderLabel()
        createHeaderView()
        createTableView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Interface Building Methods
    private func createHeaderLabel() {
        headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 43))
        headerLabel.font = UIFont(name: "Gotham-Bold", size: 39)
        headerLabel.text = dayOfCycleText
        headerLabel.numberOfLines = 0
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.minimumScaleFactor = 0.5
        headerLabel.textColor = .csbcDefaultText
        headerLabel.textAlignment = .center
        headerLabel.frame = CGRect(x: headerLabel.frame.minX + 10, y: headerLabel.frame.minY + 12, width: UIScreen.main.bounds.width - 20, height: 43)
    }
    private func createHeaderView() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        headerView.backgroundColor = .clear
        headerView.addSubview(headerLabel)
    }
    private func createTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "TodayViewCell", bundle: nil), forCellReuseIdentifier: "todayViewCell")
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

}
