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
    var todayParser : TodayDataParser? = nil
    
    var dateSentToCurrentPageVC = Date()
    var dateSentToPreviousPageVC = Date()
    var dateSentToNextPageVC = Date()
    let daySchedule = DaySchedule(forSeton: true, forJohn: true, forSaints: true, forJames: true)
    
    
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
            forDate: dateStringFormatter.string(from: dateSentToCurrentPageVC),
            forSchool: schoolSelected.ssString,
            forDayOfCycle: daySchedule.dateDayDict[schoolSelected.ssString]![dateStringFormatter.string(from: dateSentToCurrentPageVC)] ?? 0,
            athletics: todayParser?.athletics(forDate: dateSentToCurrentPageVC),
            events: todayParser?.events(forDate: dateSentToCurrentPageVC) ?? [EventsModel]())
            self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
            reloadInputViews()
    }
    
    func schoolPickerValueDidChange() {
        schoolSelected = getSchoolSelected()
        
        if todayParser != nil {
            if self.viewControllers!.count > 0 {
                //print("running this one")
                let currentVC = self.viewControllers![0] as! TodayViewController
                let controller = TodayViewController(
                    forDate: currentVC.dateShown,
                    forSchool: schoolSelected.ssString,
                    forDayOfCycle: daySchedule.dateDayDict[schoolSelected.ssString]![currentVC.dateShown] ?? 0,
                    athletics: todayParser!.athletics(forDate: dateStringFormatter.date(from: currentVC.dateShown)!),
                    events: todayParser!.events(forDate: dateStringFormatter.date(from: currentVC.dateShown)!))
                self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
            } else {
                let controller = TodayViewController(
                    forDate: dateStringFormatter.string(from: Date()),
                    forSchool: schoolSelected.ssString,
                    forDayOfCycle: daySchedule.dateDayDict[schoolSelected.ssString]![dateStringFormatter.string(from: Date())] ?? 0,
                    athletics: todayParser!.athletics(forDate: Date()),
                    events: todayParser!.events(forDate: Date()))
                self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
            }
        }

        
    }
    func storeDateSelected(date : Date) {
        let controller = TodayViewController(
            forDate: dateStringFormatter.string(from: date),
            forSchool: schoolSelected.ssString,
            forDayOfCycle: daySchedule.dateDayDict[schoolSelected.ssString]![dateStringFormatter.string(from: date)] ?? 0,
            athletics: todayParser?.athletics(forDate: date),
            events: todayParser?.events(forDate: date) ?? [EventsModel]())
        dateSentToPreviousPageVC = date
        dateSentToNextPageVC = date
        self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        dateSentToPreviousPageVC -= 86400
        let controller = TodayViewController(
            forDate: dateStringFormatter.string(from: dateSentToPreviousPageVC),
            forSchool: schoolSelected.ssString,
            forDayOfCycle: daySchedule.dateDayDict[schoolSelected.ssString]![dateStringFormatter.string(from: dateSentToPreviousPageVC)] ?? 0,
            athletics: todayParser?.athletics(forDate: dateSentToPreviousPageVC),
            events: todayParser?.events(forDate: dateSentToPreviousPageVC) ?? [EventsModel]())
        return controller
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        dateSentToNextPageVC += 86400
        let controller = TodayViewController(
            forDate: dateStringFormatter.string(from: dateSentToNextPageVC),
            forSchool: schoolSelected.ssString,
            forDayOfCycle: daySchedule.dateDayDict[schoolSelected.ssString]![dateStringFormatter.string(from: dateSentToNextPageVC)] ?? 0,
            athletics: todayParser?.athletics(forDate: dateSentToNextPageVC),
            events: todayParser?.events(forDate: dateSentToNextPageVC) ?? [EventsModel]())
        return controller
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let childVC = pageViewController.viewControllers![0] as! TodayViewController
        let dateToSend = dateStringFormatter.date(from: childVC.dateShown)!
        pagerDelegate?.showDateAsHeader(dateGiven: dateToSend)
        dateSentToNextPageVC = dateToSend
        dateSentToPreviousPageVC = dateToSend
    }
}



