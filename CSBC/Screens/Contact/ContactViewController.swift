//
//  ContactContainerViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/23/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Contains most methods for contacts page, including table data, delegates, and parallax effect. For some reason, trying to split up these methods results in the table data disappearing after loading
class ContactViewController: CSBCViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var copyrightLabel: UILabel!
    
    private var imageView = UIImageView()
    private var yearFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy"
        return fmt
    }
    
    private let sectionHeaders = ["Map","Contact","Hours of Operation"]
    private let mapImageArray = ["setonMap","saintsMap","saintsMap","jamesMap"]
    private let schoolNames = ["Seton Catholic Central", "St. John the Evangelist", "All Saints School", "St. James School"]
    private let schoolAddresses = ["70 Seminary Avenue Binghamton, NY 13905", "9 Livingston Street Binghamton NY 13903", "1112 Broad Street Endicott NY 13760", "143 Main Street Johnson City NY 13790"]
    private let schoolPhone : [[String]] = [["723.5307", "723.4811"],["723.0703","772.6210"],["748.7423"],["797.5444"]]
    private let districtPhone = "723.1547"
    private let schoolPrincipals = ["Matthew Martinkovic", "James Fountaine", "William Pipher", "Susan Kitchen"]
    private let hoursOfOperation = [
        ["Morning Bell: 8:13 AM", "Dismissal: 3:00 PM"],
        ["Before School Care: From 7:00 AM","Start: 8:30 AM","Dismissal: 2:45 PM","After School Care: Until 5:45 PM"],
        ["Before School Care: From 7:00 AM","Start: 8:20 AM","Dismissal: 2:45 PM","After School Care: Until 6:00 PM"],
        ["Before School Care: From 7:00 AM","Start: 8:20 AM","Dismissal: 3:00 PM","After School Care: Until 6:00 PM"]
    ]
    
    private let buildingImageArray = ["setonBuilding","johnBuilding","saintsBuilding","jamesBuilding"]
    private var mailController : ContactMailDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact"
        copyrightLabel.text = "© " + Date().yearString() + " Catholic Schools of Broome County"
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        mailController = ContactMailDelegate(parent: self, schoolSelected: schoolSelected)
        
        tableView.delegate = self//tableController
        tableView.dataSource = self//tableController
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [tableView], showAllSegments: true)
        super.viewWillAppear(animated)
    }
    
    override  func schoolPickerValueChanged(_ sender: CSBCSegmentedControl) {
        super.schoolPickerValueChanged(sender)
        mailController.schoolSelected = schoolSelected
        
        let imageHeight = 0.4904*UIScreen.main.bounds.width
                imageView.frame = CGRect(
                    x: 0,
                    y: 53,
                    width: UIScreen.main.bounds.size.width,
                    height: imageHeight)
        tableView.contentInset.top = imageHeight
        imageView.image = UIImage(named: buildingImageArray[schoolSelected.ssInt])!
        tableView.reloadData()
    }
    
    
    //MARK: TableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return schoolPhone[schoolSelected.ssInt].count + 2
        case 2:
            return hoursOfOperation[schoolSelected.ssInt].count
        default:
            return 1
        }
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let mapCell = tableView.dequeueReusableCell(withIdentifier: "contactInfoMapCell") as! ContactInfoMapCell
            mapCell.mapImageView.image = UIImage(named: mapImageArray[schoolSelected.ssInt])
            mapCell.buildingLabel.text = schoolNames[schoolSelected.ssInt]
            mapCell.addressLabel.text = schoolAddresses[schoolSelected.ssInt]
            return mapCell
            
        } else if indexPath.section == 1 {
            let regularCell = tableView.dequeueReusableCell(withIdentifier: "contactInfoRegularCell")
            
            if indexPath.row == 0 {
                regularCell!.textLabel?.text = "Main: 607.\(schoolPhone[schoolSelected.ssInt][0])"
                regularCell!.imageView!.image = UIImage(named: "phoneIcon")
            } else if indexPath.row == 1 {
                regularCell!.textLabel?.text = "District: 607.\(districtPhone)"
                regularCell!.imageView!.image = UIImage(named: "phoneIcon")
            } else if schoolPhone[schoolSelected.ssInt].count == 2 {
                if indexPath.row == 2 {
                    regularCell!.textLabel?.text = "Fax: 607.\(schoolPhone[schoolSelected.ssInt][1])"
                    regularCell!.imageView!.image = UIImage(named: "faxIcon")
                } else if indexPath.row == 3 {
                    regularCell!.textLabel?.text = "\(schoolPrincipals[schoolSelected.ssInt]), Principal"
                    regularCell!.imageView!.image = UIImage(named: "mailIcon")
                }
            } else {
                if indexPath.row == 2 {
                    regularCell!.textLabel?.text = "\(schoolPrincipals[schoolSelected.ssInt]), Principal"
                    regularCell!.imageView!.image = UIImage(named: "mailIcon")
                }
            }
            
            return regularCell!
            
        } else {
            let hoursCell = tableView.dequeueReusableCell(withIdentifier: "hoursOfOperationCell")
            hoursCell!.textLabel?.text = hoursOfOperation[schoolSelected.ssInt][indexPath.row]
            //regularCell!.imageView?.image = nil
            return hoursCell!
            
        }
    }
    
    
    //MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            performSegue(withIdentifier: "showMapSegue", sender: self)
        } else if schoolPhone[schoolSelected.ssInt].count == 2 && indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                UIApplication.shared.open(URL(string: "tel://607.\(schoolPhone[schoolSelected.ssInt][0])")!)
            case 1:
                UIApplication.shared.open(URL(string: "tel://607.\(districtPhone)")!)
            case 2:
                UIApplication.shared.open(URL(string: "tel://607.\(schoolPhone[schoolSelected.ssInt][1])")!)
            case 3:
                mailController.presentMailVC()
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                UIApplication.shared.open(URL(string: "tel://607.\(schoolPhone[schoolSelected.ssInt][0])")!)
            case 1:
                UIApplication.shared.open(URL(string: "tel://607.\(districtPhone)")!)
            case 2:
                mailController.presentMailVC()
            default:
                break
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageView.frame = CGRect(
                            x: 0,
                            y: 53,
                            width: UIScreen.main.bounds.size.width,
                            height: -scrollView.contentOffset.y)
        
    }
}
