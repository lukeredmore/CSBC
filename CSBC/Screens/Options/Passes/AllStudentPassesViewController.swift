//
//  AllStudentPassesViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/23/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit



class AllStudentPassesViewController: CSBCViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarContainerView: UIView!
    @IBOutlet weak var tableView: UITableView! { didSet {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.isHidden = modelArrayForSearch.count == 0
        tableView.reloadData()
    } }
    private(set) var arrayToDisplay = [[StudentPassInfo]]()
    var filteredArrayToDisplay = [StudentPassInfo]()
    private var gradeLevelMap = [Int:Int]()
    
    
    private lazy var searchControllerController = CSBCSearchController(forVC: self, in: searchBarContainerView, with: searchBarTopConstraint, ofType: .passes)
    
    private var modelArrayForSearch : [[StudentPassInfo]] {
        if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
            return [filteredArrayToDisplay]
        } else {
            return arrayToDisplay
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = tableView.isHidden ? .white : .csbcNavBarBackground
    }
    
    func addArrayOfStudents(_ arr : [StudentPassInfo], forGrade gradeLevelMap : [Int:Int]) {
        self.gradeLevelMap = gradeLevelMap
        var tempGroup = [Int:[StudentPassInfo]]()
        
        for student in arr {
            guard gradeLevelMap[student.graduationYear] != nil else { continue }
            if tempGroup[student.graduationYear] == nil {
                tempGroup[student.graduationYear] = [StudentPassInfo]()
            }
            tempGroup[student.graduationYear]?.append(student)
        }
        arrayToDisplay = Array(tempGroup.values).sorted { $0[0].graduationYear < $1[0].graduationYear }
        arrayToDisplay = arrayToDisplay.map { $0.sorted { $0.name < $1.name } }
    }

    //MARK: TableView Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int { modelArrayForSearch.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { modelArrayForSearch[section].count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard modelArrayForSearch.count > 0,
            modelArrayForSearch[0].count > 0 ,
            let grade = gradeLevelMap[modelArrayForSearch[section][0].graduationYear] else { return nil }
        if searchControllerController.searchController.isActive && searchControllerController.searchController.searchBar.text != "" {
            return nil
        } else { return "Grade \(grade)" }
    }
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allPassCell")!
        let student = modelArrayForSearch[indexPath.section][indexPath.row]
        cell.textLabel?.text = student.name
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PassDetailSegueFromAll", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PassDetailSegueFromAll",
        let passDetailVC = segue.destination as? PassDetailViewController,
        let index = tableView.indexPathForSelectedRow {
            let student = modelArrayForSearch[index.section][index.row]
            passDetailVC.addLog(for: student)
        }
    }

}