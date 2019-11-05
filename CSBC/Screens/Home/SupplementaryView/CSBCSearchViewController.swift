//
//  CSBCSearchViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 11/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

protocol Searchable : Hashable, Comparable {
    var groupIntoSectionsByThisParameter : AnyHashable { get }
    var sectionTitle : String { get }
    var searchElements : String { get }
    var shouldStayGroupedWhenSearching : Bool { get }
}

struct test : Searchable {
    let title : String
    let date : String
    let seq : Int
    
    var groupIntoSectionsByThisParameter: AnyHashable { date }
    
    var sectionTitle: String { date }
    
    var searchElements: String { title }
    
    var shouldStayGroupedWhenSearching: Bool { false }
    
    static func < (lhs: test, rhs: test) -> Bool {
        return lhs.seq < rhs.seq
    }
    
    
}

class CSBCTestSearchViewController : CSBCSearchViewController<test> {
    
    let no : Set<test> = [
        test(title: "new york", date: "12/25/2019", seq: 1),
        test(title: "london", date: "12/25/2019", seq: 2),
        test(title: "dubai", date: "12/25/2019", seq: 1),
        test(title: "hong kong", date: "11/25/2019", seq: 2),
        test(title: "berlin", date: "01/01", seq: 4),
        test(title: "sidney", date: "01/01", seq: 3),
        test(title: "shanghai", date: "01/01", seq: 2),
        test(title: "cape town", date: "01/01", seq: 1)
    ]
    let yes : Set<test> = [
        test(title: "beijing", date: "12/25/2019", seq: 1),
        test(title: "vienna", date: "12/25/2019", seq: 2),
        test(title: "chicago", date: "12/25/2019", seq: 1),
        test(title: "delhi", date: "11/25/2019", seq: 2),
        test(title: "moscow", date: "01/01", seq: 4),
        test(title: "rome", date: "01/01", seq: 3),
        test(title: "paris", date: "01/01", seq: 2),
        test(title: "madrid", date: "01/01", seq: 1)
    ]
    lazy var testd : Set<test> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Test"
        setEmptyDataMessage("abs no", whileSearching: "no filt")
        loadTable(withData: testd)
    }
    
    override func configureCell(for data: test) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "HI + \(data.title)"
        return cell
    }
    override func refreshData() {
        testd = yes == yes ? no : yes
        loadTable(withData: testd)
    }
}

class CSBCSearchViewController<T: Searchable>: CSBCViewController, UITableViewDataSource, UISearchResultsUpdating, UITableViewDelegate {
    
    //MARK: UI & Search Elements
    private let tableView = UITableView()
    private let bar = UIView()
    private let emptyDataLabel = UILabel()
    private let searchBarContainerView = UIView()
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var searchBarTopConstraint = searchBarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    private var emptyDataMessageWhileSearching = "No items found"
    private var emptyDataMessage = "No data is present"
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .gray
        
        return refreshControl
    }()
    

    //MARK: Data elements
    private var fullData = [[T]]()
    private var filteredData = [[T]]() { didSet {
        tableView.isHidden = filteredData.count == 0
    } }
    private var dataToDisplay : [[T]] {
        if isNotSearching {
            emptyDataLabel.text = fullData.isEmpty || fullData[0].isEmpty ? emptyDataMessage : ""
            tableView.refreshControl = refreshControl
            return fullData
        } else if filteredData.count > 0, filteredData[0].count > 0, !filteredData[0][0].shouldStayGroupedWhenSearching {
            emptyDataLabel.text = ""
            tableView.refreshControl = nil
            return [Array(filteredData.joined())]
        } else {
            emptyDataLabel.text = filteredData.isEmpty || filteredData[0].isEmpty ? emptyDataMessageWhileSearching : ""
            tableView.refreshControl = nil
            return filteredData
        }
    }
    
    
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadingSymbol.startAnimating()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        emptyDataLabel.frame = CGRect(x: 0, y: 24, width: UIScreen.main.bounds.width, height: 24)
        view.layoutIfNeeded()
    }
    
    
    //MARK: User-facing Methods & Properties
    /// Returns true if the user is not searching
    var isNotSearching : Bool { searchController.searchBar.text?.isEmpty ?? true }
    /// Sets data messages shown when now data is present in tableView
    /// - Parameter full: Shown when absolutely no data exists
    /// - Parameter searching: Shown when no data matching search criteria exisits
    func setEmptyDataMessage(_ full : String, whileSearching searching: String) {
        emptyDataMessageWhileSearching = searching
        emptyDataMessage = full
    }
    /// Updates full set of data
    /// - Parameter set: full unsorted/unnested data to go in tableView
    func loadTable(withData set : Set<T>) {
        fullData = set.nest()
        searchBarTopConstraint.constant = fullData.isEmpty || fullData[0].isEmpty ? -56 : 0
        tableView.reloadData()
        loadingSymbol.stopAnimating()
        refreshControl.endRefreshing()
    }
    /// Override this function to return a UITableViewCell appropriately styled for the given object
    /// - Parameter data: Searchable object to display in a UITableViewCell
    func configureCell(for data: T) -> UITableViewCell {
        return UITableViewCell()
    }
    /// Refresh data from source. Override this method and call its super to ensure refreshes cannot occur simultaneously. Be sure to call loadTable(withData:) to reload
    @objc func refreshData() {
        guard loadingSymbol.isHidden && !refreshControl.isRefreshing else { return }
    }
    
    
    //MARK: UISearchResultsUpdating Methods
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredData = fullData.map { $0.filter { $0.searchElements.lowercased().contains(searchText.lowercased()) } }
            tableView.reloadData()
        }
    }
    
    
    //MARK: UITableView's UIScrollViewDelegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isNotSearching || fullData.isEmpty || fullData[0].isEmpty { return }
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
        return configureCell(for: dataToDisplay[indexPath.section][indexPath.row])
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
            (dataToDisplay[section][0].shouldStayGroupedWhenSearching || isNotSearching) else { return nil }
        return dataToDisplay[section][0].sectionTitle
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .csbcTableSeparator

        let headerLabel = UILabel(frame: CGRect(x: 11, y: 4, width:
        tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "gotham-bold", size: 16.5)
        headerLabel.textColor = .csbcDefaultText
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        self.tableView(tableView, titleForHeaderInSection: section) != nil ? 28 : 0 }
    
    
    //MARK: Create UI
    private func setupUI() {
        view.backgroundColor = .csbcNavBarBackground
        definesPresentationContext = true
        
        configureSearchElements(container: searchBarContainerView, controller: searchController, topConstraint: searchBarTopConstraint)
        configureYellowBar(bar)
        configureBackgroundView(UIView())
        configureBackgroundLabel(emptyDataLabel)
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
        controller.searchBar.searchField.clearButtonMode = .always
        controller.searchBar.searchField.backgroundColor = .csbcLightGreen
        controller.searchBar.searchField.textColor = .white
        controller.searchBar.backgroundImage = UIImage()
        controller.searchBar.clipsToBounds = true
        controller.searchBar.placeholder = "Search"
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
        label.font = UIFont(name: "Gotham-BookItalic", size: 19)!
        label.textColor = .csbcGrayLabel
        label.text = emptyDataMessage
        view.addSubview(label)
        view.addConstraints([
            label.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 20),
            label.heightAnchor.constraint(equalToConstant: 24),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
    }
}

extension UISearchBar {

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
