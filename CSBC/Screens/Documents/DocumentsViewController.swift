//
//  DocumentsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/8/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import PDFKit

///Documents screen's table view methods, supplies title of PDF to display to ActualDocVC
class DocumentsViewController: CSBCViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    let documentTitles = [["SCC Parent - Student Handbook", "SCC Bell Schedule", "SCC Course Description and Information Guide", "SCC Monthly Calendar", "CSBC Calendar", "SCC Dress Code"],[""],["All Saints Cafeteria Info","All Saints Illness Policy"],["St. James Parent - Student Handbook","St. James Code of Conduct"]]
    let pdfTitleStrings = [["scchandbook","sccbellschedule","scccoursedescription","sccmonthlycalendar","csbccalendar","sccdresscode"],[],["saintscafeteriainfo","saintssickpolicy"],["jameshandbook","jamescodeofconduct"]]
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Documents"
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [tableView])
        super.viewWillAppear(animated)
    }
    override func schoolPickerValueChanged(_ sender: CSBCSegmentedControl) {
        super.schoolPickerValueChanged(sender)
        tableView.reloadData()
    }
    

    //MARK: Table Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentTitles[schoolSelected.ssInt].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentsTableCell", for: indexPath)
        cell.textLabel!.text = documentTitles[schoolSelected.ssInt][indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDocument", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDocument" {
            let childVC = segue.destination as! ActualDocViewController
            if let path = Bundle.main.path(forResource: "\(pdfTitleStrings[schoolSelected.ssInt][tableView.indexPathForSelectedRow?.row ?? 0])19-20", ofType: "pdf") {
                let url = URL(fileURLWithPath: path)
                childVC.documentToDisplay = PDFDocument(url: url)
            }
        }
     }
}
