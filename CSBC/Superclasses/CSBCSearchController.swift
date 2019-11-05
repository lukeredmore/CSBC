//
//  CSBCSearchController.swift
//  CSBC
//
//  Created by Luke Redmore on 7/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UIKit

enum CSBCSearchable {
    case athletics, events, passes
}

///Can search both athletics and calendar views to create filtered arrays for their respective VCs to display
class CSBCSearchController : NSObject, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate {
    
//    var athleticsParent : AthleticsViewController!
    var eventsParent : CalendarViewController!
    var passesParent : AllStudentPassesViewController!
    let type : CSBCSearchable
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarTopConstraint : NSLayoutConstraint!
    var parent : UIViewController!
    
    init(forVC vc: UIViewController, in searchBarContainerView : UIView, with searchBarTopConstraint : NSLayoutConstraint, ofType type: CSBCSearchable) {
        self.type = type
        super.init()
        switch type {
        case .athletics:
            print("hi")
//            athleticsParent = vc as? AthleticsViewController
        case .events:
            eventsParent = vc as? CalendarViewController
        case .passes:
            passesParent = vc as? AllStudentPassesViewController
        }
        self.searchBarTopConstraint = searchBarTopConstraint
        setupSearchController(searchBarContainerView)
    }
    private func setupSearchController(_ searchBarContainerView : UIView) {
        
        searchBarContainerView.backgroundColor = .csbcNavBarBackground
        searchBarContainerView.addSubview(searchController.searchBar)
        searchBarContainerView.bringSubviewToFront(searchController.searchBar)
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.barTintColor = .csbcNavBarBackground
        searchController.searchBar.searchField.clearButtonMode = .always
        searchController.searchBar.searchField.backgroundColor = .csbcLightGreen
        searchController.searchBar.searchField.textColor = .white
        
        searchController.searchBar.searchField.attributedPlaceholder = NSAttributedString(
                string: searchController.searchBar.searchField.placeholder ?? "",
                attributes: [
                    NSAttributedString.Key.foregroundColor : UIColor.white
                ]
            )
        
        
        if let leftView = searchController.searchBar.searchField.leftView as? UIImageView {
            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
            leftView.tintColor = UIColor.white
        }
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.clipsToBounds = true
        searchController.searchBar.placeholder = "Search"
        switch type {
        case .athletics:
            print("hi")
//            athleticsParent.definesPresentationContext = true
        case .events:
            eventsParent.definesPresentationContext = true
        case .passes:
            passesParent.definesPresentationContext = true
        }
        //view.layoutIfNeeded()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let term = searchController.searchBar.text {
            switch type {
            case .athletics:
                filterAthleticsRows(forText: term)
            case .events:
                filterEventsRows(forText: term)
            case .passes:
                filterPassRows(forText: term)
            }
        }
    }
    
    
    //MARK: Actual filtering
    private func filterAthleticsRows(forText searchText: String) {
        
//        let arrayShorter = athleticsParent!.athleticsData.athleticsModelArray
//        guard arrayShorter != [] else { return }
//        athleticsParent!.athleticsData.athleticsModelArrayFiltered.removeAll()
//
//        var includedModelsList : [Int] = []
//        var includedIndicesList : [Int] = []
//        if arrayShorter.count > 0, arrayShorter[0] != nil {
//            for date in arrayShorter.indices {
//                for event in arrayShorter[date]!.title.indices {
//                    if arrayShorter[date]!.title[event].lowercased().contains(searchText.lowercased()) {
//                        includedModelsList.append(date)
//                        includedIndicesList.append(event)
//                    } else if arrayShorter[date]!.level[event].lowercased().contains(searchText.lowercased()) {
//                        includedModelsList.append(date)
//                        includedIndicesList.append(event)
//                    } else if arrayShorter[date]!.time[event].lowercased().contains(searchText.lowercased()) {
//                        includedModelsList.append(date)
//                        includedIndicesList.append(event)
//                    } else if arrayShorter[date]!.date.lowercased().contains(searchText.lowercased()) {
//                        includedModelsList.append(date)
//                        includedIndicesList.append(event)
//                    }
//                }
//            }
//        }
//        athleticsParent!.athleticsData.addToFilteredModelArray(modelsToInclude: includedModelsList, indicesToInclude: includedIndicesList)
//        athleticsParent!.tableView.reloadData()
    }
    private func filterEventsRows(forText searchText : String) {
        let filteredArray = eventsParent.calendarData.eventsModelArray.filter {
            $0.event.lowercased().contains(searchText.lowercased()) ||
            $0.date.day!.stringValue!.contains(searchText.lowercased()) ||
            $0.time?.lowercased().contains(searchText.lowercased()) ?? false ||
            $0.schools?.lowercased().contains(searchText.lowercased()) ?? false
        }
        
        eventsParent.calendarData.setFilteredModelArray(toArray: filteredArray)
        eventsParent.tableView.reloadData()
    }
    func filterEventsRowsForSchoolsSelected(_ schoolsList : [Bool]) {
        let filteredArray = eventsParent.calendarData.eventsModelArray.filter {
            (schoolsList[0] && $0.schools?.contains("Seton") ?? false) ||
            (schoolsList[1] && $0.schools?.contains("John") ?? false) ||
            (schoolsList[2] && $0.schools?.contains("Saints") ?? false) ||
            (schoolsList[3] && $0.schools?.contains("James") ?? false) ||
            ($0.schools == "")
        }
        
        eventsParent.calendarData.setFilteredModelArray(toArray: filteredArray)
        eventsParent.tableView.reloadData()
    }
    
    func filterPassRows(forText searchText : String) {
        passesParent.filteredArrayToDisplay = passesParent.arrayToDisplay.flatMap({ $0 }).filter {
            $0.currentStatus.0.lowercased().contains(searchText.lowercased()) || $0.name.lowercased().contains(searchText.lowercased())
        }
        passesParent.tableView.reloadData()
    }
    
    
    //MARK: Table and Scroll Delegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Gotham-Bold", size: 18)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    
    
}
