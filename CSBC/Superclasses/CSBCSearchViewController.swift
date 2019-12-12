//
//  CSBCSearchViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 11/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol Searchable : Hashable, Comparable, Codable {
    var groupIntoSectionsByThisParameter : AnyHashable? { get }
    var sectionTitle : String? { get }
    var searchElements : String { get }
    static var shouldStayGroupedWhenSearching : Bool? { get }
    static func sortSectionsByThisParameter<T: Comparable>(_ lhs: T, _ rhs: T) -> Bool?
}

protocol DisplayInSearchableTableView {
    func addData<T: Searchable>(_ genericModel : T)
}

enum RefreshConfiguration {
    case whileNotSearching, never
}

class CSBCSearchViewController<T: Searchable, Cell: UITableViewCell>: CSBCViewController, UITableViewDataSource, UISearchResultsUpdating, UITableViewDelegate, UISearchControllerDelegate where Cell : DisplayInSearchableTableView {
    
    //MARK: UI & Search Elements
    let tableView = UITableView()
    private let header = UIView()
    private let bar = UIView()
    private let emptyDataLabel = UILabel()
    private let backgroundButton = UIButton()
    private lazy var searchController = UISearchController()
    private lazy var emptyDataMessageWhileSearching = configuration.emptySearchMessage
    private lazy var emptyDataMessage = configuration.emptyDataMessage
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
        
        return refreshControl
    }()
    
    
    //MARK: Configuration Properties
    private let configuration : CSBCSearchConfiguration!
    private lazy var cellID = configuration.xibIdentifier
    private lazy var refreshConfiguration = configuration.refreshConfiguration
    private lazy var allowSelection = configuration.allowSelection
    private lazy var searchPlaceholder = configuration.searchPlaceholder
    private lazy var backgroundButtonText : String? = configuration.backgroundButtonText
    
    init(configuration : CSBCSearchConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    //MARK: Data elements
    private var fullData = [[T]]()
    private var filteredData = [[T]]()
    private var searchedData = [[T]]()
    
    private var dataToDisplay : [[T]] {
        var dataToReturn : [[T]]
        if isSearching {
            isRefreshEnabled = false
            if !searchedDataEmpty, !(T.shouldStayGroupedWhenSearching ?? false) {
                dataToReturn = [Array(searchedData.joined())]
                emptyDataLabel.text = ""
                backgroundButton.setTitle("", for: .normal)
            } else {
                emptyDataLabel.text = searchedDataEmpty ? emptyDataMessageWhileSearching : ""
                backgroundButton.setTitle(searchedDataEmpty ? backgroundButtonText : "", for: .normal)
                dataToReturn = searchedData
            }
        } else if !filters.isEmpty {
            isRefreshEnabled = refreshConfiguration == .whileNotSearching
            emptyDataLabel.text = filteredDataEmpty ? emptyDataMessageWhileSearching : ""
            backgroundButton.setTitle(filteredDataEmpty ? backgroundButtonText : "", for: .normal)
            dataToReturn = filteredData
        } else {
            emptyDataLabel.text = fullDataEmpty ? emptyDataMessage : ""
            backgroundButton.setTitle(fullDataEmpty ? backgroundButtonText : "", for: .normal)
            isRefreshEnabled = refreshConfiguration == .whileNotSearching
            dataToReturn = fullData
        }
        tableView.isHidden = dataToReturn.count == 0 || dataToReturn[0].count == 0
        return dataToReturn
    }
    
    private var isRefreshEnabled : Bool{
        get { tableView.refreshControl != nil }
        set (newValue) { tableView.refreshControl = newValue ? refreshControl : nil }
    }
    private var fullDataEmpty : Bool {
        guard fullData.count > 0 else { return true }
        return fullData[0].count == 0
    }
    private var filteredDataEmpty : Bool {
        guard filteredData.count > 0 else { return true }
        return filteredData[0].count == 0
    }
    private var searchedDataEmpty : Bool {
        guard searchedData.count > 0 else { return true }
        return searchedData[0].count == 0
    }
    
    //MARK: View Control
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingSymbol.startAnimating()
        self.headerHeightConstraint.constant = self.maxHeaderHeight
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        emptyDataLabel.frame = CGRect(x: 0, y: 24, width: UIScreen.main.bounds.width, height: 24)
        view.layoutIfNeeded()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let bkgButtonText = configuration.backgroundButtonText else { return }
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 54))
        let button = UIButton(frame: footer.bounds)
        button.addTarget(self, action: #selector(backgroundButtonPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        button.setTitleColor(.csbcAlwaysGray, for: .normal)
        button.setTitle(bkgButtonText, for: .normal)
        footer.addSubview(button)
        footer.backgroundColor = .csbcBackground
        tableView.tableFooterView = footer
    }
    
    //MARK: User-facing Methods & Properties
    /// Returns true if the user is searching
    var isSearching : Bool { !(searchController.searchBar.text?.isEmpty ?? true) }
    /// Updates full set of data
    /// - Parameter set: full unsorted/unnested data to go in tableView
    func loadTable(withData set : Set<T>) {
        fullData = set.nest()
        tableView.reloadData()
        loadingSymbol.stopAnimating()
        refreshControl.endRefreshing()
    }
    /// Refresh data from source. Override this method and call its super to ensure refreshes cannot occur simultaneously. Be sure to call loadTable(withData:) to reload
    @objc func refreshData() {
        guard loadingSymbol.isHidden && !refreshControl.isRefreshing else { return }
    }
    /// Array of 'permanent search parameters' to serve as filters
    var filters = [String]() { didSet {
        let filteredSet = Set(fullData.joined()).filter {
            for each in filters where $0.searchElements.lowercased().contains(each.lowercased()) {
                return true
            }
            return false
        }
        filteredData = filteredSet.nest()
        tableView.reloadData()
    } }
    /// Override this to control what happens when a cell is selcted
    /// - Parameter model: The Searchable object the selected cell is displaying
    func cellSelected(withModel model : T) {}
    /// Override this to control what happens when a background button is pressed, be sure to include super
    /// - Parameter sender: Button object pressed
    @objc func backgroundButtonPressed() {
        guard loadingSymbol.isHidden else { return }
        searchController.dismiss(animated: false) { self.searchController.searchBar.text = "" }
    }
    
    
    //MARK: UISearchResultsUpdating Methods
    func updateSearchResults(for searchController: UISearchController) {
        if var searchText = searchController.searchBar.text?.configureForSearch().components(separatedBy: " ") {
            searchText.removeAll { $0 == "" }
            searchedData = fullData.map { $0.filter {
                for textToSearch in searchText where !$0.searchElements.configureForSearch().contains(textToSearch) {
                    return false
                }
                return true
            } }
            searchedData.removeAll { $0.count == 0 }
            tableView.reloadData()
        }
    }
    
    
    //MARK: UITableView's UIScrollViewDelegate Methods
    private let maxHeaderHeight: CGFloat = 64;
    private let minHeaderHeight: CGFloat = 8;
    private lazy var headerHeightConstraint = header.heightAnchor.constraint(equalToConstant: maxHeaderHeight)
    private var previousScrollOffset: CGFloat = 0
    private var previousScrollViewHeight: CGFloat = 0
    
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
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
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
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - minHeaderHeight

        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight && !searchController.isActive
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
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)

        if self.headerHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    private func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.view.layoutIfNeeded()
        })
    }
    private func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.view.layoutIfNeeded()
        })
    }
    
    
    //MARK: UITableViewDelagate Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? Cell else { fatalError("No cell is defined") }
        cell.addData(dataToDisplay[indexPath.section][indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dataToDisplay.count > 0 else { return 0 }
        return dataToDisplay[section].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataToDisplay.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard dataToDisplay.count > section, dataToDisplay[section].count > 0,
            (T.shouldStayGroupedWhenSearching ?? false || !isSearching) else { return nil }
        return dataToDisplay[section][0].sectionTitle
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .csbcTableSeparator

        let headerLabel = UILabel(frame:
            CGRect(x: 11, y: 4, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        )
        headerLabel.font = UIFont(name: "gotham-bold", size: 18)
        headerLabel.textColor = .csbcDefaultText
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        self.tableView(tableView, titleForHeaderInSection: section) != nil ? 28.5 : 0 }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard loadingSymbol.isHidden else { return }
        cellSelected(withModel: dataToDisplay[indexPath.section][indexPath.row])
    }
    
    
    //MARK: UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        configureSearchBar(controller: self.searchController)
    }
    
    
    //MARK: Create UI
    private func setupUI() {
        title = configuration.pageTitle
        view.backgroundColor = .csbcNavBarBackground
        definesPresentationContext = true
        
        configureHeader(header)
        configureBackgroundView(UIView())
        configureBackgroundLabel(emptyDataLabel)
        configureBackgroundButton(backgroundButton)
        configureYellowBar(bar)
        configureSearchBar(controller: searchController)
        configureTableView(tableView)
        view.bringSubviewToFront(loadingSymbol)
        view.sendSubviewToBack(header)
        view.layoutIfNeeded()
        self.previousScrollViewHeight = self.tableView.contentSize.height

    }
    private func configureHeader(_ header : UIView) {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .csbcNavBarBackground
        view.addSubview(header)
        view.addConstraints([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerHeightConstraint,
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    private func configureYellowBar(_ bar : UIView) {
        bar.backgroundColor = .csbcYellow
        bar.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(bar)
        header.addConstraints([
            bar.heightAnchor.constraint(equalToConstant: 8),
            bar.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            bar.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: header.trailingAnchor)
        ])
    }
    private func configureSearchBar(controller : UISearchController) {
            controller.searchBar.translatesAutoresizingMaskIntoConstraints = false
            controller.searchBar.removeFromSuperview()
            header.addSubview(controller.searchBar)
            header.addConstraints([
                controller.searchBar.bottomAnchor.constraint(equalTo: bar.topAnchor),
                controller.searchBar.leadingAnchor.constraint(equalTo: header.leadingAnchor),
                controller.searchBar.trailingAnchor.constraint(equalTo: header.trailingAnchor)
            ])
            
            controller.delegate = self
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.tintColor = .white
            controller.searchBar.isTranslucent = false
            controller.searchBar.barTintColor = .csbcNavBarBackground
            controller.searchBar.searchField.backgroundColor = .csbcLightGreen
            controller.searchBar.searchField.textColor = .white
            controller.searchBar.backgroundImage = UIImage()
            controller.searchBar.clipsToBounds = true
            controller.searchBar.placeholder = searchPlaceholder
            controller.searchBar.setPlaceholder(textColor: .white)
            controller.searchBar.setSearchImage(color: .white)
            controller.searchBar.searchField.clearButtonMode = .never
        }
    private func configureBackgroundView(_ bgView : UIView) {
        bgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        view.addConstraints([
            bgView.topAnchor.constraint(equalTo: header.bottomAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        bgView.backgroundColor = .csbcBackground
    }
    private func configureBackgroundLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "Gotham-BookItalic", size: 18)!
        label.numberOfLines = 0
        label.clipsToBounds = false
        label.textColor = .csbcGrayLabel
        label.text = emptyDataMessage
        view.addSubview(label)
        view.addConstraints([
            label.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20),
            label.heightAnchor.constraint(equalToConstant: label.text?.height(withConstrainedWidth: view.frame.width - 20, font: UIFont(name: "Gotham-BookItalic", size: 18)!) ?? 30),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    private func configureBackgroundButton(_ button : UIButton) {
        guard backgroundButtonText != nil else { return }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "gotham", size: 18)!
        button.setTitle(backgroundButtonText, for: .normal)
        button.setTitleColor(.csbcAlwaysGray, for: .normal)
        button.addTarget(self, action: #selector(backgroundButtonPressed), for: .touchUpInside)
        view.addSubview(button)
        view.addConstraints([
            button.topAnchor.constraint(equalTo: emptyDataLabel.bottomAnchor, constant: 20),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    private func configureTableView(_ tableView : UITableView) {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        tableView.allowsSelection = allowSelection
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}

fileprivate extension UISearchBar {

    func setPlaceholder(textColor: UIColor) { searchField.setPlaceholder(textColor: textColor) }

    func setSearchImage(color: UIColor) {
        guard let imageView = searchField.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

fileprivate extension UITextField {

    private class ColoredLabel: UILabel {
        private var _textColor = UIColor.lightGray
        override var textColor: UIColor! {
            set { super.textColor = _textColor }
            get { return _textColor }
        }

        init(_ label : UILabel, textColor : UIColor) {
            _textColor = textColor
            super.init(frame: label.frame)
            self.text = label.text
            self.font = label.font
        }
        
        required init?(coder: NSCoder) { super.init(coder: coder) }
    }
    
    
    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = value(forKey: "placeholderLabel") as? UILabel else { return }
        let coloredLabel = ColoredLabel(placeholderLabel, textColor: textColor)
        setValue(coloredLabel, forKey: "placeholderLabel")
    }
}

struct CSBCSearchConfiguration {
    /// Title of the page
    let pageTitle : String
    /// Message shown when no data is present
    let emptyDataMessage : String
    /// Message shown when no data matches search criteria
    let emptySearchMessage : String
    /// Name of class and xib containing custom cell
    let xibIdentifier : String
    /// Set configuration of how refresh should be allowed
    let refreshConfiguration : RefreshConfiguration
    /// Allow selection of elements in tableView
    let allowSelection : Bool
    /// Text displayed as a search placeholder
    let searchPlaceholder : String
    /// Text of button shown when table view is empty, set to nil to disable. Calls backgroundButtonPressed(_:) when tapped.
    let backgroundButtonText : String?
}


