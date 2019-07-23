//
//  TodayViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol SendScheduleToPageVC: class {
    func storeSchedules(athletics: AthleticsDataParser, events: EventsParsing)
}

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    //var athleticsModelArray : [AthleticsModel]
    var tableView : UITableView!
    var headerLabel : UILabel!
    var headerView : UIView!
    var athleticsData : AthleticsDataParser = AthleticsDataParser()
    var calendarData : EventsParsing = EventsParsing()
    var forSchool : String!
    var dayOfCycle : Int!
    //lazy var loadingSymbol: UIActivityIndicatorView!
//    let loadingSymbol : UIActivityIndicatorView = {
//        let loadingSymbol = UIActivityIndicatorView(style: .whiteLarge)
//        loadingSymbol.hidesWhenStopped = true
//        loadingSymbol.frame.origin = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
//        loadingSymbol.color = .gray
//        return loadingSymbol
//    }()
    var todaysEvents : [[String:String]] = [[:]]
    var ogTodaysEvents : [[String:String]] = [[:]]
    var todaysAthletics : AthleticsModel? = nil
    let sectionNames = ["Events","Sports"]
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var eventsReadyToLoad = false
    var athleticsReadyToLoad = false
    var dateShown : String!
    var monthDayDateString : String!
    weak var eventsDelegate : SendScheduleToPageVC? = nil
    weak var pageViewDidLoadDelegate : PageViewLoadedDelegate? = nil
    var fmt : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.register(UINib(nibName: "TodayViewCell", bundle: nil), forCellReuseIdentifier: "todayViewCell")
        tableView.delegate = self
        findEvent()
    }
    
    init(forDate : String, forSchool : String, forDayOfCycle : Int, athletics : AthleticsDataParser, events : EventsParsing) {
        self.dateShown = forDate
        self.athleticsData = athletics
        self.calendarData = events
        self.forSchool = forSchool
        self.dayOfCycle = forDayOfCycle
        
        super.init(nibName: nil, bundle: nil)
//        view.addSubview(loadingSymbol)
//        view.bringSubviewToFront(loadingSymbol)
//        loadingSymbol.startAnimating()
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        createHeader()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        //tableView.backgroundColor = .clear
        self.view.addSubview(tableView)
        setConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func createHeader() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        headerView.backgroundColor = .clear
        headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 43))
        headerLabel.font = UIFont(name: "Gotham-Bold", size: 39)
        headerLabel.text = getDayOfCycle(dayOfCycle)
        headerLabel.numberOfLines = 0
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.minimumScaleFactor = 0.5
        if #available(iOS 13.0, *) {
            headerLabel.textColor = .label
        } else {
            headerLabel.textColor = .darkText
        }
        headerLabel.textAlignment = .center
        headerView.addSubview(headerLabel)
        //headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.frame = CGRect(x: headerLabel.frame.minX + 10, y: headerLabel.frame.minY + 12, width: UIScreen.main.bounds.width - 20, height: 43)
    }
    
    func getDayOfCycle(_ day : Int) -> String {
        if dayOfCycle != 0 {
            return "Today is Day \(dayOfCycle!)"
        } else {
            return "There is no school today"
        }
    }
    
    func findEvent() {
        if athleticsData.athleticsModelArray.count > 0 {
            print("using old athletics data")
            prepAthleticsDataForTableView()
        } else {
            print("getting new athletics data")
            getAthleticsData()
        }
        
        if calendarData.filteredEventArrayNoDuplicates.count > 1 { //&& calendarData.filteredEventArrayNoDuplicates[0] != [:] {
            print("using old calendar data")
            prepCalendarDataForTableView()
        } else {
            print("getting new calendar data")
            getCalendarEvents()
        }
        
        
    }
    
    func getAthleticsData() {
        let parameters = ["game_types" : ["regular_season", "scrimmage", "post_season", "event"]]
        Alamofire.request("https://www.schedulegalaxy.com/api/v1/schools/163/activities", method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Athletics Data Received")
                let athleticsJSON : JSON = JSON(response.result.value!)
                //print("Be prepin")
                self.athleticsData.parseAthleticsData(json: athleticsJSON)
                self.prepAthleticsDataForTableView()
                
            }
            
        }
    }
    
    func prepAthleticsDataForTableView() {
        todaysAthletics = nil
        athleticsReadyToLoad = false
        //var todaysDateString = fmt.string(from: dateToShow)
        let athleticsDateFormatter = DateFormatter()
        athleticsDateFormatter.dateFormat = "MMMM dd"
        monthDayDateString = athleticsDateFormatter.string(from: fmt.date(from: dateShown)!)
        for dateWithEvents in athleticsData.athleticsModelArray {
            if dateWithEvents.date.contains(monthDayDateString) {
                todaysAthletics = dateWithEvents
            }
        }
//        if todaysAthletics.count == 0 {
//            print("there are no sports today")
//        } else {
//            if todaysAthletics[0] == [:] {
//                todaysAthletics.removeFirst()
//            }
//        }
        athleticsReadyToLoad = true
        tryToLoadTableView()
    }
    
    func getCalendarEvents() {
        Alamofire.request("https://csbcsaints.org/calendar").responseString(queue: nil, encoding: .utf8) { response in
            if let html = response.result.value {
                //let date = Date()
                //print("data received at \(date)")
                if html.contains("span") {
                    self.calendarData.parseHTMLForEvents(html: html)
                    self.prepCalendarDataForTableView()
                    
                }
            }
        }
    }
    
    func prepCalendarDataForTableView() {
        //print("Be preppin")
        todaysEvents = [[:]]
        eventsReadyToLoad = false
        let todaysDateArray = dateShown.components(separatedBy: "/")
        let dateShownForCalendar = "\(months[Int(todaysDateArray[0])!-1]) \(todaysDateArray[1])"
        for i in 0..<calendarData.filteredEventArrayNoDuplicates.count {
            if calendarData.filteredEventArrayNoDuplicates[i]["date"] == dateShownForCalendar {
                todaysEvents.append(calendarData.filteredEventArrayNoDuplicates[i])
            }
        }
        if todaysEvents.count == 0 {
            print("there are no events today")
            //            todaysEvents = [["time":"There are no calendar events today."]]
        } else {
            if todaysEvents[0] == [:] {
                todaysEvents.removeFirst()
            }
            
        }
        ogTodaysEvents = todaysEvents
        filterEventsOnlyForSchool()
        eventsReadyToLoad = true
        tryToLoadTableView()
        
        
    }
    
    func filterEventsOnlyForSchool() {
        var todaysEventsForSchool : [[String:String]] = [[:]]
        //print(ogTodaysEvents)
        //print("todaysevents[0] is \(todaysEvents[0])")
        if ogTodaysEvents.count > 0 {
            if ogTodaysEvents.count > 1 || ogTodaysEvents[0] != [:] {
                for i in 0..<ogTodaysEvents.count {
                    //print(ogTodaysEvents)
                    if ogTodaysEvents[i]["schools"]!.contains(forSchool) {
                        todaysEventsForSchool.append(ogTodaysEvents[i])
                    }
                }
            }
        }
        
        
        todaysEvents = todaysEventsForSchool
        if todaysEvents[0] == [:] {
            todaysEvents.removeFirst()
        }
        tableView.reloadData()
    }
    
    func tryToLoadTableView() {
        print("Trying to load tableView")
        //print(todaysEvents)
        if eventsReadyToLoad && athleticsReadyToLoad {
            eventsDelegate?.storeSchedules(athletics: athleticsData, events: calendarData)
            tableView.dataSource = self
            tableView.reloadData()
            pageViewDidLoadDelegate?.pageViewDidLoad()
            print("TableView loaded")
            //filterEventsOnlyForSchool()
            //loadingSymbol.stopAnimating()
            
        }
    }
    
    
    //MARK: TableView Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if todaysEvents.count != 0 {
                return todaysEvents.count
            } else {
                return 1
            }
        } else {
            if todaysAthletics != nil {
                return todaysAthletics!.sport.count
            } else {
                return 1
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todayViewCell") as! TodayViewCell
        if #available(iOS 13.0, *) {
            cell.titleLabel.textColor = .label
            cell.levelLabel.textColor = .secondaryLabel
            cell.timeLabel.textColor = .secondaryLabel
        } else {
            cell.titleLabel.textColor = .darkText
            cell.levelLabel.textColor = .darkText
            cell.timeLabel.textColor = .darkText
        }
        if indexPath.section == 1 {
            if todaysAthletics != nil {
                cell.titleHeightConstraint.constant = 50
                cell.titleLabel.text = "\(todaysAthletics!.gender[indexPath.row])'s \(todaysAthletics!.sport[indexPath.row]) \(todaysAthletics!.homeGame[indexPath.row]) \(todaysAthletics!.opponent[indexPath.row])"
                cell.timeLabel.text = todaysAthletics!.time[indexPath.row]
                cell.levelLabel.text = todaysAthletics!.level[indexPath.row]
            } else {
                cell.timeLabel.text = "There are no events today"
                cell.titleLabel.text = nil
                cell.levelLabel.text = nil
                cell.titleHeightConstraint.constant = 33
            }
        } else {
            if todaysEvents.count > 0 && todaysEvents[0] != [:] {
                cell.titleHeightConstraint.constant = 50
                cell.titleLabel.text = todaysEvents[indexPath.row]["event"]
                cell.timeLabel.text = todaysEvents[indexPath.row]["time"]
                cell.levelLabel.text = todaysEvents[indexPath.row]["schools"]
            } else {
                cell.timeLabel.text = "There are no events today"
                cell.titleLabel.text = nil
                cell.levelLabel.text = nil
                cell.titleHeightConstraint.constant = 33
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
    
}
