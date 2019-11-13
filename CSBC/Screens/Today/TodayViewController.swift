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
    let date : Date!
    private let todayView : TodayView!
    
    private let todayDataSource : TodayDataSource!
    
    
    //MARK: Init Methods
    init(date : Date, dayOfCycle : Int?, athleticsModel : Set<AthleticsModel>?, eventsModel : Set<EventsModel>?) {
        self.date = date
        self.todayView = TodayView(forDay: dayOfCycle ?? 0)
        self.todayDataSource = TodayDataSource(todaysEvents: eventsModel, todaysAthletics: athleticsModel, date: date)
        super.init(nibName: nil, bundle: nil)
        todayView.tableView.dataSource = todayDataSource
        todayView.tableView.reloadData()
        view = todayView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
