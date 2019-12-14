//
//  SearchScrollDelegate.swift
//  CSBC
//
//  Created by Luke Redmore on 12/11/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class SearchScrollDelegate: NSObject, UITableViewDelegate {
    static let maxHeaderHeight : CGFloat = 64;
    static let minHeaderHeight : CGFloat = 8;
    
    private var headerHeightConstraint : NSLayoutConstraint!
    private var tableView : UITableView!
    private var view : UIView!
    
    init(headerConstraint: NSLayoutConstraint, tableView: UITableView, view: UIView) {
        self.headerHeightConstraint = headerConstraint
        self.tableView = tableView
        self.view = view
    }
    
    private var previousScrollOffset: CGFloat = 0
    var previousScrollViewHeight: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Always update the previous values
        defer {
            self.previousScrollViewHeight = scrollView.contentSize.height
            self.previousScrollOffset = scrollView.contentOffset.y
        }

        let heightDiff = scrollView.contentSize.height - self.previousScrollViewHeight
        let scrollDiff = (scrollView.contentOffset.y - self.previousScrollOffset)

        // If the scroll was caused by the height of the scroll view changing, we want to do nothing.
        guard heightDiff == 0 else { return }

        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;

        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom

        if canAnimateHeader(scrollView) {

            // Calculate new header height
            var newHeight = self.headerHeightConstraint.constant
            if isScrollingDown {
                newHeight = max(SearchScrollDelegate.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(SearchScrollDelegate.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
            }

            // Header needs to animate
            if newHeight != self.headerHeightConstraint.constant {
                self.headerHeightConstraint.constant = newHeight
                self.setScrollPosition(self.previousScrollOffset)
            }
        }
    }

    private func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - SearchScrollDelegate.minHeaderHeight

        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight// && !searchController.isActive
    }
    private func setScrollPosition(_ position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { self.scrollViewDidStopScrolling() }
    }
    private func scrollViewDidStopScrolling() {
        let range = SearchScrollDelegate.maxHeaderHeight - SearchScrollDelegate.minHeaderHeight
        let midPoint = SearchScrollDelegate.minHeaderHeight + (range / 2)

        if self.headerHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    private func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = SearchScrollDelegate.minHeaderHeight
            self.view.layoutIfNeeded()
        })
    }
    private func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = SearchScrollDelegate.maxHeaderHeight
            self.view.layoutIfNeeded()
        })
    }
}
