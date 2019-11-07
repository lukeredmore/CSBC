//
//  TodayPageViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 4/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Creates and organizes TodayVCs to be swiped through. Requests data through TodayDataParser, and populates TodayVC
class TodayPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, InputUpdateDelegate {
    var schoolSelected : Schools {
        return Schools(rawValue: UserDefaults.standard.integer(forKey:"schoolSelected")) ?? .seton
    }
    
    weak var pagerDelegate : PageViewDelegate!
    private lazy var todayParser = TodayDataParser()
    
    private var dateSentToCurrentPageVC = Date()
    private var dateSentToPreviousPageVC = Date()
    private var dateSentToNextPageVC = Date()
    
    
    //MARK: View Control
    override func viewDidLoad() {
        self.delegate = self
        self.dataSource = self
        let controller = TodayViewController(
            date: dateSentToCurrentPageVC,
            dayOfCycle: DaySchedule.day(on: dateSentToCurrentPageVC, for: schoolSelected),
            athleticsModel: todayParser.athletics(forDate: dateSentToCurrentPageVC),
            eventsModel: todayParser.events(forDate: dateSentToCurrentPageVC))
        self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        reloadInputViews()
    }
    
    
    //MARK: Input Update Delegate Methods
    func schoolPickerValueDidChange() {
        if viewControllers!.count > 0 {
            guard let currentDate = (viewControllers![0] as! TodayViewController).date else { fatalError("Date is nil") }
            let controller = TodayViewController(
                date: currentDate,
                dayOfCycle: DaySchedule.day(on: currentDate, for: schoolSelected),
                athleticsModel: todayParser.athletics(forDate: currentDate),
                eventsModel: todayParser.events(forDate: currentDate))
            self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        } else {
            let controller = TodayViewController(
                date: Date(),
                dayOfCycle: DaySchedule.day(on: Date(), for: schoolSelected),
                athleticsModel: todayParser.athletics(forDate: Date()),
                eventsModel: todayParser.events(forDate: Date()))
            self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        }
    }
    func storeDateSelected(date : Date) {
        let controller = TodayViewController(
            date: date,
            dayOfCycle: DaySchedule.day(on: date, for: schoolSelected),
            athleticsModel: todayParser.athletics(forDate: date),
            eventsModel: todayParser.events(forDate: date))
        pagerDelegate.dateToShow = date
        dateSentToPreviousPageVC = date
        dateSentToNextPageVC = date
        self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
    }
    
    
    //MARK: Page VC delegate methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        dateSentToPreviousPageVC -= 86400
        let controller = TodayViewController(
            date: dateSentToPreviousPageVC,
            dayOfCycle: DaySchedule.day(on: dateSentToPreviousPageVC, for: schoolSelected),
            athleticsModel: todayParser.athletics(forDate: dateSentToPreviousPageVC),
            eventsModel: todayParser.events(forDate: dateSentToPreviousPageVC))
        return controller
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        dateSentToNextPageVC += 86400
        let controller = TodayViewController(
            date: dateSentToNextPageVC,
            dayOfCycle: DaySchedule.day(on: dateSentToNextPageVC, for: schoolSelected),
            athleticsModel: todayParser.athletics(forDate: dateSentToNextPageVC),
            eventsModel: todayParser.events(forDate: dateSentToNextPageVC))
        return controller
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if viewControllers!.count > 0 {
            guard let dateToSend = (viewControllers![0] as? TodayViewController)?.date
                else { fatalError("Couldn't find date of view controllers") }
            pagerDelegate.dateToShow = dateToSend
            dateSentToNextPageVC = dateToSend
            dateSentToPreviousPageVC = dateToSend
        }
        
    }
}



