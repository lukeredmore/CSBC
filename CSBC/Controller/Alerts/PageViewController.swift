//
//  PageViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol TellDateShownToParentVC: class  {
    func showDateAsHeader(dateGiven : Date)
}
protocol SchoolSelectedForPageDelegate: class {
    func storeSchoolSelected(schoolSelected : String)
}
protocol DateForPageDelegate: class {
    func storeDateSelected(date : Date)
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, SendScheduleToPageVC, SchoolSelectedForPageDelegate, DateForPageDelegate {
    
    var fmt : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        return fmt
    }
    var dateSentToCurrentPageVC = Date()
    var dateSentToPreviousPageVC = Date()
    var dateSentToNextPageVC = Date()
    weak var dateDelegate : TellDateShownToParentVC? = nil
    var testVar : String!
    var athleticsData = AthleticsData()
    var calendarData = EventsParsing()
    var schoolSelected = "Seton"
    let daySchedule : DaySchedule = DaySchedule(forSeton: true, forJohn: true, forSaints: true, forJames: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(schoolSelected, "selected on viewWillAppear in PageViewController")
        let controller = TodayViewController(forDate: fmt.string(from: dateSentToCurrentPageVC), forSchool: schoolSelected, forDayOfCycle: daySchedule.dateDayDict[schoolSelected]![fmt.string(from: dateSentToCurrentPageVC)] ?? 0, athletics: self.athleticsData, events: self.calendarData)
        controller.pageViewDidLoadDelegate = parent as! TodayContainerViewController
        self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
    }
    
    func storeSchedules(athletics: AthleticsData, events: EventsParsing) {
        self.athleticsData = athletics
        self.calendarData = events
        reloadInputViews()
    }

    func storeSchoolSelected(schoolSelected: String) {
        //print(schoolSelected)
        self.schoolSelected = schoolSelected
        
        if self.viewControllers!.count > 0 {
            //print("running this one")
            let currentVC = self.viewControllers![0] as! TodayViewController
            let controller = TodayViewController(forDate: currentVC.dateShown, forSchool: schoolSelected, forDayOfCycle: daySchedule.dateDayDict[schoolSelected]![currentVC.dateShown] ?? 0, athletics: self.athleticsData, events: self.calendarData)
            controller.pageViewDidLoadDelegate = parent as! TodayContainerViewController
            self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        } else {
            //print("that olne")
            let controller = TodayViewController(forDate: fmt.string(from: Date()), forSchool: schoolSelected, forDayOfCycle: daySchedule.dateDayDict[schoolSelected]![fmt.string(from: Date())] ?? 0, athletics: self.athleticsData, events: self.calendarData)
            controller.pageViewDidLoadDelegate = parent as! TodayContainerViewController
            self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        }
    }
    func storeDateSelected(date : Date) {
        let controller = TodayViewController(forDate: fmt.string(from: date), forSchool: schoolSelected, forDayOfCycle: daySchedule.dateDayDict[schoolSelected]![fmt.string(from: date)] ?? 0, athletics: self.athleticsData, events: self.calendarData)
        dateSentToPreviousPageVC = date
        dateSentToNextPageVC = date
        controller.pageViewDidLoadDelegate = parent as! TodayContainerViewController
        self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        dateSentToPreviousPageVC -= 86400
        let controller = TodayViewController(forDate: fmt.string(from: dateSentToPreviousPageVC), forSchool: schoolSelected, forDayOfCycle: daySchedule.dateDayDict[schoolSelected]![fmt.string(from: dateSentToPreviousPageVC)] ?? 0, athletics: self.athleticsData, events: self.calendarData)
        return controller
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        dateSentToNextPageVC += 86400
        let controller = TodayViewController(forDate: fmt.string(from: dateSentToNextPageVC), forSchool: schoolSelected, forDayOfCycle: daySchedule.dateDayDict[schoolSelected]![fmt.string(from: dateSentToNextPageVC)] ?? 0, athletics: self.athleticsData, events: self.calendarData)
        return controller
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let childVC = pageViewController.viewControllers![0] as! TodayViewController
        childVC.eventsDelegate = self
        childVC.pageViewDidLoadDelegate = parent as! TodayContainerViewController
        let dateToSend = fmt.date(from: childVC.dateShown)!
        dateDelegate?.showDateAsHeader(dateGiven: dateToSend)
        dateSentToNextPageVC = dateToSend
        dateSentToPreviousPageVC = dateToSend
        
    }
    
    
    
//    func createViewController() -> UIViewController {
//        var randomColor: UIColor {
//            return UIColor(hue: CGFloat(arc4random_uniform(360))/360, saturation: 0.5, brightness: 0.8, alpha: 1)
//        }
//        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        //let controller = storyboard.instantiateViewController(withIdentifier: "AlertsViewController")
//        let controller = TodayViewController(forDate: fmt.string(from: Date()))
//        //controller.view.backgroundColor = randomColor
//        return controller
//    }
    
    
}



