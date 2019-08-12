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
    init(date : Date, dayOfCycle : Int, athleticsModel : AthleticsModel?, eventsModel : [EventsModel]) {
        self.date = date
        self.todayView = TodayView(forDay: dayOfCycle)
        self.todayDataSource = TodayDataSource(todaysEvents: eventsModel, todaysAthletics: athleticsModel)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        todayView.tableView.dataSource = todayDataSource
        todayView.tableView.reloadData()
        view = todayView
        print("TableView loaded")
    }
}
