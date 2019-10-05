//
//  PassDetailViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 10/4/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Shows past pass activity with data from parent VC (PassesViewController)
class PassDetailViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak private var explicitNavItem: UINavigationItem!
    @IBOutlet weak private var tableView : UITableView!
    
    var logToDisplay = [(StudentPassStatus, Date)]()
    var titleToSet = String()
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        explicitNavItem.title = titleToSet
    }
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logToDisplay.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy - h:mm a"
        
        logToDisplay.sort { $0.1 > $1.1 }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PassLogCell")!
        cell.textLabel?.text = dateFormatter.string(from: logToDisplay[indexPath.row].1)
        cell.detailTextLabel?.text = logToDisplay[indexPath.row].0.stringValue()
        return cell
    }
    
}
