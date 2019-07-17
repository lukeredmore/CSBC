//
//  DocumentsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/8/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import PDFKit

class DocumentsViewController: CSBCViewController, UITableViewDataSource, UITableViewDelegate {
    
    var row = 0
    var section = 0
    var loadedPdfs : [[Int:PDFDocument]] = [[:]]
    @IBOutlet var tableView: UITableView!
    let documentTitles = [["SCC Parent - Student Handbook", "SCC Bell Schedule", "SCC Course Description and Information Guide", "SCC Monthly Calendar", "CSBC Calendar", "SCC Dress Code"],[""],["All Saints Cafeteria Info","All Saints Illness Policy"],["St. James Parent - Student Handbook","St. James Code of Conduct"]]
    let pdfFiles = [["scchandbook18-19","sccbellschedule18-19","scccoursedescription18-19","sccmonthlycalendar18-19","csbccalendar18-19","sccdresscode18-19"],[],["saintscafeteriainfo18-19","saintssickpolicy18-19"],["jameshandbook18-19","jamescodeofconduct18-19"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Documents"
        tableView.tableFooterView = UIView()
        loadedPdfs.removeAll()
        //print("loading")
        for pdfsBySchool in pdfFiles {
            var loadedPdfsToAppend : [Int:PDFDocument] = [:]
            for i in 0..<pdfsBySchool.count {
                if let path = Bundle.main.path(forResource: pdfsBySchool[i], ofType: "pdf") {
                    let url = URL(fileURLWithPath: path)
                    if let pdfDocument = PDFDocument(url: url) {
                        loadedPdfsToAppend[i] = pdfDocument
                    }
                }
            }
            loadedPdfs.append(loadedPdfsToAppend)
        }
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
        row = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        if loadedPdfs[schoolSelected.ssInt][row] != nil {
            performSegue(withIdentifier: "toDocument", sender: self)
        }
    }
    
    
    // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDocument" {
            let childVC = segue.destination as! ActualDocViewController //!!
            childVC.clickedDocument = loadedPdfs[schoolSelected.ssInt][row]
        }
     }
}
