//
//  CSBCSearchController.swift
//  CSBC
//
//  Created by Luke Redmore on 7/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UIKit

///Can search both athletics and calendar views to create filtered arrays for their respective VCs to display
class CSBCSearchController : NSObject, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate {
    
    var athleticsParent : AthleticsViewController? = nil
    var eventsParent : CalendarViewController? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarTopConstraint : NSLayoutConstraint!
    var parent : UIViewController!
    
    init(searchBarContainerView : UIView, searchBarTopConstraint : NSLayoutConstraint, athleticsParent : AthleticsViewController? = nil, eventsParent : CalendarViewController? = nil) {
        super.init()
        if (athleticsParent != nil && eventsParent == nil) || (athleticsParent == nil && eventsParent != nil) {
            if athleticsParent != nil {
                self.athleticsParent = athleticsParent
                parent = athleticsParent!
            } else if eventsParent != nil {
                self.eventsParent = eventsParent
                parent = eventsParent!
            }
            self.searchBarTopConstraint = searchBarTopConstraint
            setupSearchController(searchBarContainerView)
        }
    }
    private func setupSearchController(_ searchBarContainerView : UIView) {
        
        //tableView.tableHeaderView = searchController.searchBar
        searchBarContainerView.addSubview(searchController.searchBar)
        searchBarContainerView.bringSubviewToFront(searchController.searchBar)
        searchController.searchBar.sizeToFit()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.barTintColor = .csbcGreen
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
        if athleticsParent != nil {
            athleticsParent!.definesPresentationContext = true
        } else if eventsParent != nil {
            eventsParent!.definesPresentationContext = true
        }
        //view.layoutIfNeeded()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let term = searchController.searchBar.text {
            if athleticsParent != nil && athleticsParent!.athleticsData.athleticsModelArray != [] {
                filterAthleticsRowsForSearchedText(term)
            } else if eventsParent != nil {
                filterEventsRowsForSearchedText(term)
            }
            
        }
    }
    private func filterAthleticsRowsForSearchedText(_ searchText: String) {
        let arrayShorter = athleticsParent!.athleticsData.athleticsModelArray
        athleticsParent!.athleticsData.athleticsModelArrayFiltered.removeAll()
        var includedModelsList : [Int] = []
        var includedIndicesList : [Int] = []
        if arrayShorter.count > 0 {
            if arrayShorter[0] != nil {
                for date in arrayShorter.indices {
                    for event in arrayShorter[date]!.title.indices {
                        if arrayShorter[date]!.title[event].lowercased().contains(searchText.lowercased()) {
                            includedModelsList.append(date)
                            includedIndicesList.append(event)
                        } else if arrayShorter[date]!.level[event].lowercased().contains(searchText.lowercased()) {
                            includedModelsList.append(date)
                            includedIndicesList.append(event)
                        } else if arrayShorter[date]!.time[event].lowercased().contains(searchText.lowercased()) {
                            includedModelsList.append(date)
                            includedIndicesList.append(event)
                        } else if arrayShorter[date]!.date.lowercased().contains(searchText.lowercased()) {
                            includedModelsList.append(date)
                            includedIndicesList.append(event)
                        }
                    }
                }
            }
        }
        athleticsParent!.athleticsData.addToFilteredModelArray(modelsToInclude: includedModelsList, indicesToInclude: includedIndicesList)
        athleticsParent!.tableView.reloadData()
    }
    private func filterEventsRowsForSearchedText(_ searchText : String) {
        let arrayShorter = eventsParent!.calendarData.eventsModelArray
        eventsParent!.calendarData.eventsModelArrayFiltered.removeAll()
        var includedModelsList : [Int] = []
        if arrayShorter.count > 0 {
            if arrayShorter[0] != nil {
                for n in arrayShorter.indices {
                    if arrayShorter[n]!.date.lowercased().contains(searchText.lowercased()) {
                        includedModelsList.append(n)
                    } else if arrayShorter[n]!.day.lowercased().contains(searchText.lowercased()) {
                        includedModelsList.append(n)
                    } else if arrayShorter[n]!.month.lowercased().contains(searchText.lowercased()) {
                        includedModelsList.append(n)
                    } else if arrayShorter[n]!.time.lowercased().contains(searchText.lowercased()) {
                        includedModelsList.append(n)
                    } else if arrayShorter[n]!.event.lowercased().contains(searchText.lowercased()) {
                        includedModelsList.append(n)
                    } else if arrayShorter[n]!.schools.lowercased().contains(searchText.lowercased()) {
                        includedModelsList.append(n)
                    }
                }
                
            }
        }
        
        eventsParent!.calendarData.addToFilteredModelArray(modelsToInclude: includedModelsList)
        eventsParent!.tableView.reloadData()
    }
    func filterEventsRowsForSchoolsSelected(_ schoolsList : [Bool]) {
        let arrayShorter = eventsParent!.calendarData.eventsModelArray
        eventsParent!.calendarData.eventsModelArrayFiltered.removeAll()
        var includedModelsList : [Int] = []
        if arrayShorter[0] != nil {
            for n in arrayShorter.indices {
                if schoolsList[0] && arrayShorter[n]!.schools.contains("Seton") {
                    includedModelsList.append(n)
                } else if schoolsList[1] && arrayShorter[n]!.schools.contains("John") {
                    includedModelsList.append(n)
                } else if schoolsList[2] && arrayShorter[n]!.schools.contains("Saints") {
                    includedModelsList.append(n)
                } else if schoolsList[3] && arrayShorter[n]!.schools.contains("James") {
                    includedModelsList.append(n)
                } else if arrayShorter[n]!.schools == "" {
                    includedModelsList.append(n)
                }
            }
        }
        
        eventsParent!.calendarData.addToFilteredModelArray(modelsToInclude: includedModelsList)
        eventsParent!.tableView.reloadData()
    }
    
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if eventsParent?.eventsDataPresent ?? false || athleticsParent?.athleticsDataPresent ?? false {
            let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            if translation.y > 0 && searchController.searchBar.text == "" && searchBarTopConstraint.constant != 0 && !searchController.isActive { //scroll up
                if translation.y < 56 {
                    searchBarTopConstraint.constant = translation.y - 56 //show search bar growing
                } else if translation.y == 56 {
                    searchBarTopConstraint.constant = 0
                }
                self.parent.view.layoutIfNeeded()
            } else if translation.y < 0 && searchController.searchBar.text == "" && searchBarTopConstraint.constant != -56 && !searchController.isActive { //scroll down
                if translation.y > -56 {
                    searchBarTopConstraint.constant = translation.y //show search bar shrinking
                } else if translation.y == -56 {
                    searchBarTopConstraint.constant = -56
                }
                self.parent.view.layoutIfNeeded()
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView.superview)
        if searchBarTopConstraint.constant < -45 {
            searchBarTopConstraint.constant = -56
        } else {
            searchBarTopConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.1) {
            self.parent.view.layoutIfNeeded()
        }
    }
    
    
}