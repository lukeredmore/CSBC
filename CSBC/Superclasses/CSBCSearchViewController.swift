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

class CSBCSearchViewController<T: Searchable, Cell: UITableViewCell>: CSBCViewController, UITableViewDataSource, UISearchResultsUpdating, UITableViewDelegate where Cell : DisplayInSearchableTableView {
    
    //MARK: UI & Search Elements
    let tableView = UITableView()
    private let bar = UIView()
    private let emptyDataLabel = UILabel()
    private let backgroundButton = UIButton()
    private let searchBarContainerView = UIView()
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var searchBarTopConstraint = searchBarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarTopConstraint.constant = dataToDisplay.count == 0 || dataToDisplay[0].count == 0 ? -56 : 0
        loadingSymbol.startAnimating()
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
        searchBarTopConstraint.constant = fullDataEmpty ? -56 : 0
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
            var include = false
            for each in filters where $0.searchElements.lowercased().contains(each.lowercased()) {
                include = true
            }
            return include
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
        if let searchText = searchController.searchBar.text {
            searchedData = fullData.map { $0.filter { $0.searchElements.lowercased().contains(searchText.lowercased()) } }
            tableView.reloadData()
        }
    }
    
    
    //MARK: UITableView's UIScrollViewDelegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSearching || fullDataEmpty { return }
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0 && searchBarTopConstraint.constant != 0 { //scroll up
            if translation.y < 56 {
                searchBarTopConstraint.constant = translation.y - 56 //show search bar growing
            } else if translation.y == 56 {
                searchBarTopConstraint.constant = 0
            }
            view.layoutIfNeeded()
        } else if translation.y < 0 && searchBarTopConstraint.constant != -56 { //scroll down
            if translation.y > -56 {
                searchBarTopConstraint.constant = translation.y //show search bar shrinking
            } else if translation.y == -56 {
                searchBarTopConstraint.constant = -56
            }
            view.layoutIfNeeded()
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
            self.view.layoutIfNeeded()
        }
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

        let headerLabel = UILabel(frame: CGRect(x: 11, y: 4, width:
        tableView.bounds.size.width, height: tableView.bounds.size.height))
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
    
    
    //MARK: Create UI
    private func setupUI() {
        title = configuration.pageTitle
        view.backgroundColor = .csbcNavBarBackground
        definesPresentationContext = true
        
        configureSearchElements(container: searchBarContainerView, controller: searchController, topConstraint: searchBarTopConstraint)
        configureYellowBar(bar)
        configureBackgroundView(UIView())
        configureBackgroundLabel(emptyDataLabel)
        configureBackgroundButton(backgroundButton)
        configureTableView(tableView)
        view.bringSubviewToFront(loadingSymbol)
        view.layoutIfNeeded()
    }
    private func configureSearchElements(container : UIView, controller : UISearchController, topConstraint: NSLayoutConstraint) {
        container.backgroundColor = .csbcNavBarBackground
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        view.addConstraints([
            topConstraint,
            container.heightAnchor.constraint(equalToConstant: 56),
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        container.addSubview(controller.searchBar)
        
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
    private func configureYellowBar(_ bar : UIView) {
        bar.backgroundColor = .csbcYellow
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        view.addConstraints([
            bar.topAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor),
            bar.heightAnchor.constraint(equalToConstant: 8),
            bar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    private func configureBackgroundView(_ bgView : UIView) {
        bgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        view.addConstraints([
            bgView.topAnchor.constraint(equalTo: bar.bottomAnchor),
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
            label.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 20),
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
            tableView.topAnchor.constraint(equalTo: bar.bottomAnchor),
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


