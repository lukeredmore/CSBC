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
    
    @IBOutlet weak private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak private var copyrightLabel: UILabel! {
        didSet { copyrightLabel.text = "© \(Date().yearString()) Catholic Schools of Broome County" }
    }
    
    private var imageView = UIImageView()
    
    private let sectionHeaders = ["Map","Contact","Hours of Operation"]
    private var address : String? { StaticData.readData(atPath: "\(schoolSelected.singleStringLowercase)/info/address") }
    private var districtPhone : String? { StaticData.readData(atPath: "general/districtPhone") }
    private var fax : String? { StaticData.readData(atPath: "\(schoolSelected.singleStringLowercase)/info/fax") }
    private var phone : String? { StaticData.readData(atPath: "\(schoolSelected.singleStringLowercase)/info/phone") }
    private var principalName : String? { StaticData.readData(atPath: "\(schoolSelected.singleStringLowercase)/info/principal") }
    private var hoo : [String]? { StaticData.readData(atPath: "\(schoolSelected.singleStringLowercase)/info/hoo")?.components(separatedBy: "\n") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact"
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [tableView], showAllSegments: true)
        super.viewWillAppear(animated)
    }
    
    override func schoolPickerValueChanged() {
        let imageHeight = 0.4904*UIScreen.main.bounds.width
        imageView.frame = CGRect(
            x: 0,
            y: 53,
            width: UIScreen.main.bounds.size.width,
            height: imageHeight)
        tableView.contentInset.top = imageHeight
        imageView.image = UIImage(named: "\(schoolSelected.singleStringLowercase)Building")!
        tableView.setContentOffset(CGPoint(x: 0, y: -184), animated: false)
        tableView.reloadData()
    }
    
    
    //MARK: TableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return fax?.hasData() ?? false ? 4 : 3
        case 2:
            return hoo?.count ?? 0
        default:
            return 1
        }
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { sectionHeaders[section] }
    func numberOfSections(in tableView: UITableView) -> Int { 3 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let mapCell = tableView.dequeueReusableCell(withIdentifier: "contactInfoMapCell") as! ContactInfoMapCell
            mapCell.mapImageView.image = UIImage(named: "\(schoolSelected.singleStringLowercase)Map")
            mapCell.buildingLabel.text = schoolSelected.fullName
            mapCell.addressLabel.text = address
            return mapCell
            
        } else if indexPath.section == 1 {
            let regularCell = tableView.dequeueReusableCell(withIdentifier: "contactInfoRegularCell")
            
            if indexPath.row == 0, let phone = phone {
                regularCell!.textLabel?.text = "Main: \(phone)"
                regularCell!.imageView!.image = UIImage(named: "phoneIcon")
            } else if indexPath.row == 1, let districtPhone = districtPhone {
                regularCell!.textLabel?.text = "District: \(districtPhone)"
                regularCell!.imageView!.image = UIImage(named: "phoneIcon")
            } else if fax?.hasData() ?? false {
                if indexPath.row == 2 {
                    regularCell!.textLabel?.text = "Fax: \(fax!)"
                    regularCell!.imageView!.image = UIImage(named: "faxIcon")
                } else if indexPath.row == 3, principalName != nil {
                    regularCell!.textLabel?.text = "\(principalName!), Principal"
                    regularCell!.imageView!.image = UIImage(named: "mailIcon")
                }
            } else if indexPath.row == 2, principalName != nil {
                regularCell!.textLabel?.text = "\(principalName!), Principal"
                regularCell!.imageView!.image = UIImage(named: "mailIcon")
            }
            
            return regularCell!
            
        } else {
            let hoursCell = tableView.dequeueReusableCell(withIdentifier: "hoursOfOperationCell")
            hoursCell!.textLabel?.text = hoo?[indexPath.row]
            return hoursCell!
            
        }
    }
    
    
    //MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            performSegue(withIdentifier: "showMapSegue", sender: self)
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                UIApplication.shared.open(URL(string: "tel://\(phone?.replacingOccurrences(of: " ", with: "") ?? "")")!)
            case 1:
                UIApplication.shared.open(URL(string: "tel://\(districtPhone?.replacingOccurrences(of: " ", with: "") ?? "")")!)
            case 2:
                fax?.hasData() ?? false ? UIApplication.shared.open(URL(string: "tel://\(fax!.replacingOccurrences(of: " ", with: ""))")!) : present(ContactMailDelegate.getMailVC(forSchool: schoolSelected), animated: true)
            case 3:
                present(ContactMailDelegate.getMailVC(forSchool: schoolSelected), animated: true)
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
