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

class CSBCSearchViewController<T: Searchable, Cell: UITableViewCell>: UIViewController, UITableViewDataSource, UISearchResultsUpdating, UITableViewDelegate, UISearchControllerDelegate where Cell : DisplayInSearchableTableView {
    
    //MARK: UI & Search Elements
    private lazy var ui = CSBCSearchUI(
        loadingSymbol: searchLoadingSymbol,
        tableView: tableView,
        searchController: searchController,
        configuration: configuration,
        backgroundButtonPressed: privateBackgroundButtonPressed)
    var tableView = UITableView()
    var searchLoadingSymbol = UIActivityIndicatorView()
    private var searchController = UISearchController()
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
        return refreshControl
    }()
    private func privateBackgroundButtonPressed() {
        guard searchLoadingSymbol.isHidden else { return }
        searchController.dismiss(animated: false) { self.searchController.searchBar.text = "" }
        backgroundButtonPressed()
    }
    
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
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    

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
                ui.emptyDataLabel.text = ""
                ui.backgroundButton.setTitle("", for: .normal)
            } else {
                ui.emptyDataLabel.text = searchedDataEmpty ? configuration.emptySearchMessage : ""
                ui.backgroundButton.setTitle(searchedDataEmpty ? backgroundButtonText : "", for: .normal)
                dataToReturn = searchedData
            }
        } else if !filters.isEmpty {
            isRefreshEnabled = refreshConfiguration == .whileNotSearching
            ui.emptyDataLabel.text = filteredDataEmpty ? configuration.emptySearchMessage : ""
            ui.backgroundButton.setTitle(filteredDataEmpty ? backgroundButtonText : "", for: .normal)
            dataToReturn = filteredData
        } else {
            ui.emptyDataLabel.text = fullDataEmpty ? configuration.emptyDataMessage : ""
            ui.backgroundButton.setTitle(fullDataEmpty ? backgroundButtonText : "", for: .normal)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        searchLoadingSymbol.startAnimating()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ui.headerHeightConstraint.constant = SearchScrollDelegate.maxHeaderHeight
        tableView.reloadData()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        ui.emptyDataLabel.frame = CGRect(x: 0, y: 24, width: UIScreen.main.bounds.width, height: 24)
        view.layoutIfNeeded()
    }
    
    //MARK: User-facing Methods & Properties
    /// Returns true if the user is searching
    var isSearching : Bool { !(searchController.searchBar.text?.isEmpty ?? true) }
    /// Updates full set of data
    /// - Parameter set: full unsorted/unnested data to go in tableView
    func loadTable(withData set : Set<T>, isDummyData dummy : Bool) {
        fullData = set.nest()
        tableView.reloadData()
        if !dummy { searchLoadingSymbol.stopAnimating() }
        refreshControl.endRefreshing()
    }
    /// Refresh data from source. Override this method and call its super to ensure refreshes cannot occur simultaneously. Be sure to call loadTable(withData:) to reload
    @objc func refreshData() {
        guard searchLoadingSymbol.isHidden && !refreshControl.isRefreshing else { return }
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
    /// Returns the action items to be displayed when a cell is force pressed
    /// - Parameter model: The Searchable object the selected cell is displaying
    @available(iOS 13.0, *)
    func createContextMenuActions(for model : T) -> [UIMenuElement] { [] }
    /// Override this to control what happens when a cell is selcted
    /// - Parameter model: The Searchable object the selected cell is displaying
    func cellSelected(withModel model : T, forCell cell : Cell) {}
    /// Override this to control what happens when a background button is pressed,
    func backgroundButtonPressed() {}
    
    
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
    private lazy var scrollDelegate = SearchScrollDelegate(headerConstraint: ui.headerHeightConstraint, tableView: tableView, view: view)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !searchController.isActive else { return }
        scrollDelegate.scrollViewDidScroll(scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate.scrollViewDidEndDecelerating(scrollView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDelegate.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
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
        guard let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? Cell else { return }
        cell.becomeFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        guard searchLoadingSymbol.isHidden else { return }
        cellSelected(withModel: dataToDisplay[indexPath.section][indexPath.row], forCell: cell)
    }
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard searchLoadingSymbol.isHidden else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let model = self.dataToDisplay[indexPath.section][indexPath.row]
            return UIMenu(title: "", children: self.createContextMenuActions(for: model))
        }
    }
    
    
    //MARK: UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        ui.resetSearchBarUI(controller: self.searchController)
    }
    
    
    //MARK: Create UI
    private func setupUI() {
        title = configuration.pageTitle
        definesPresentationContext = true
        
        ui.frame = view.frame
        view = ui
        view.layoutIfNeeded()
        scrollDelegate.previousScrollViewHeight = self.tableView.contentSize.height

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
            
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        tableView.reloadData()
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
    let allowSelection : TableSelectionConfiguration
    /// Text displayed as a search placeholder
    let searchPlaceholder : String
    /// Text of button shown when table view is empty, set to nil to disable. Calls backgroundButtonPressed(_:) when tapped.
    let backgroundButtonText : String?
    
    var tappable : Bool { self.allowSelection != .none }
}
enum TableSelectionConfiguration {
    case selection, contextMenu, none
}

