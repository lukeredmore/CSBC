//
//  PageViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Creates and organizes TodayVCs to be swiped through. Requests data through TodayDataParser, and populates TodayVC
class PageViewController: CSBCPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ContainerViewDelegate, TodayParserDelegate {
    weak var pagerDelegate : PageViewDelegate? = nil
    private var todayParser : TodayDataParser? = nil
    
    private var dateSentToCurrentPageVC = Date()
    private var dateSentToPreviousPageVC = Date()
    private var dateSentToNextPageVC = Date()
    private let daySchedule = DaySchedule(forSeton: true, forJohn: true, forSaints: true, forJames: true)
    
    
    //MARK: View Control
    override func viewWillAppear(_ animated: Bool) {
        todayParser = TodayDataParser(delegate: self)
    }
    
    //MARK: Today Parser Delegate Method
    func startupPager() {
        self.delegate = self
        self.dataSource = self
        pagerDelegate?.scheduleDataDidDownload()
        let controller = TodayViewController(
            date: dateSentToCurrentPageVC,
            dayOfCycle: daySchedule.getDay(forSchool: schoolSelected, forDate: dateSentToCurrentPageVC),
            athleticsModel: todayParser?.athletics(forDate: dateSentToCurrentPageVC),
            eventsModel: todayParser?.events(forDate: dateSentToCurrentPageVC) ?? [EventsModel]())
        self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        reloadInputViews()
    }
    
    func schoolPickerValueDidChange() {
        schoolSelected = getSchoolSelected()
        
        if todayParser != nil {
            if viewControllers!.count > 0 {
                guard let currentDate = (viewControllers![0] as! TodayViewController).date else { fatalError("Date is nil") }
                let controller = TodayViewController(
                    date: currentDate,
                    dayOfCycle: daySchedule.getDay(forSchool: schoolSelected, forDate: currentDate),
                    athleticsModel: todayParser!.athletics(forDate: currentDate),
                    eventsModel: todayParser!.events(forDate: currentDate))
                self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
            } else {
                let controller = TodayViewController(
                    date: Date(),
                    dayOfCycle: daySchedule.getDay(forSchool: schoolSelected, forDate: Date()),
                    athleticsModel: todayParser!.athletics(forDate: Date()),
                    eventsModel: todayParser!.events(forDate: Date()))
                self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
            }
        }

        
    }
    func storeDateSelected(date : Date) {
        let controller = TodayViewController(
            date: date,
            dayOfCycle: daySchedule.getDay(forSchool: schoolSelected, forDate: date),
            athleticsModel: todayParser?.athletics(forDate: date),
            eventsModel: todayParser?.events(forDate: date) ?? [EventsModel]())
        dateSentToPreviousPageVC = date
        dateSentToNextPageVC = date
        self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        dateSentToPreviousPageVC -= 86400
        let controller = TodayViewController(
            date: dateSentToPreviousPageVC,
            dayOfCycle: daySchedule.getDay(forSchool: schoolSelected, forDate: dateSentToPreviousPageVC),
            athleticsModel: todayParser?.athletics(forDate: dateSentToPreviousPageVC),
            eventsModel: todayParser?.events(forDate: dateSentToPreviousPageVC) ?? [EventsModel]())
        return controller
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        dateSentToNextPageVC += 86400
        let controller = TodayViewController(
            date: dateSentToNextPageVC,
            dayOfCycle: daySchedule.getDay(forSchool: schoolSelected, forDate: dateSentToNextPageVC),
            athleticsModel: todayParser?.athletics(forDate: dateSentToNextPageVC),
            eventsModel: todayParser?.events(forDate: dateSentToNextPageVC) ?? [EventsModel]())
        return controller
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if viewControllers!.count > 0 {
            guard let dateToSend = (viewControllers![0] as! TodayViewController).date else { fatalError("Date is nil") }
            pagerDelegate?.showDateAsHeader(dateGiven: dateToSend)
            dateSentToNextPageVC = dateToSend
            dateSentToPreviousPageVC = dateToSend
        }
        
    }
}



