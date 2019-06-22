//
//  SocialMediaController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/18/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class SocialMediaController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var schoolSelected = ""
    weak var delegate: SchoolSelectedDelegate? = nil
    let tableHeaders = ["Twitter", "Facebook", "Instagram"]
    let headerDeepLinkPrefixes = ["twitter://user?screen_name=", "fb://profile/", "instagram://user?username="]
    let headerSafariPrefixes = ["https://twitter.com/", "https://facebook.com/", "https://instagram.com/"]
    let socialArray = [
        [ //Seton
            ["Catholic Schools of Broome County", "Dr. Elizabeth Carter, President", "Seton Catholic Central", "Matthew Martinkovic, Principal", "SCC Student Council", "SCC Key Club", "SCC Fan Club", "SCC Junior Fan Club"], //t
            ["Catholic Schools of Broome County", "Seton Catholic Central", "SCC Junior Fan Club"], //f
            ["SCC Junior Fan Club"] //i
        ],[ //St. John's
            ["Catholic Schools of Broome County", "Dr. Elizabeth Carter, President", "St. John School"], //t
            ["Catholic Schools of Broome County", "St. John School"] //f
        ],[ //All Saints
            ["Catholic Schools of Broome County", "Dr. Elizabeth Carter, President", "Angela Tierno-Sherwood, Principal"], // t
            ["Catholic Schools of Broome County", "All Saints School"] //f
        ],[ //St. James
            ["Catholic Schools of Broome County", "Dr. Elizabeth Carter, President", "St. James School", "Suzy Kitchen, Principal"], //t
            ["Catholic Schools of Broome County", "St. James School"], //f
            ["St. James School", "Suzy Kitchen"] //i
        ]
    ]
    let socialURLArray = [
        [ //Seton
            ["CatholicSchools", "CatholicSchPres", "SetonCatholicNY", "SCCPrincipal", "studentcouncSCC", "scckeyclub", "sccgreenhouse", "SCCJrFanClub"], //t
            ["103950839670987", "197877966951594", "608965236166888"], //f
            ["sccjrfanclub"] //i
        ],[ //St. John's
            ["CatholicSchools", "CatholicSchPres", "StJohnSchoolBin"], //t
            ["103950839670987", "399338100169777"] //f
        ],[ //All Saints
            ["CatholicSchools", "CatholicSchPres", "atierno_"], //t
            ["103950839670987", "210263249141313"]//f
        ],[ //St. James
            ["CatholicSchools", "CatholicSchPres", "StJamesSchoolJC", "StJamesJC"], //t
            ["103950839670987", "136066559773647"], //f
            ["stjamesschooljc", "stjamesjcprincipal"] //i
        ]
    ]
    var selectedSocial : [[String]] = [[]]
    var selectedSocialURL : [[String]] = [[]]
    @IBOutlet var tableView: UITableView!
    @IBOutlet var schoolPicker: UISegmentedControl!
    
    //MARK: - New school picker properties
    let schoolPickerDictionary : [String:Int] = ["Seton":0,"St. John's":1,"All Saints":2,"St. James":3]
    var editedSchoolNames : [String] = []
    var schoolSelectedInt = 0
    @IBOutlet weak var schoolPickerHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Connect"
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shouldIShowAllSchools(schoolPicker: schoolPicker, schoolPickerHeightConstraint: schoolPickerHeightConstraint)
        schoolSelectedInt = schoolPickerDictionary[schoolSelected] ?? 0
        for i in 0..<schoolPicker.numberOfSegments {
            if schoolPicker.titleForSegment(at: i) == schoolSelected {
                schoolPicker.selectedSegmentIndex = i
                //print("\(i) was selected")
            } //else { print("\(i) wasn't selected") }
        }
        tableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.storeSchoolSelected(schoolSelected: self.schoolSelected)
    }
    
    @IBAction func schoolSelectedChanged(_ sender: Any) {
        schoolSelected = schoolPicker.titleForSegment(at: schoolPicker.selectedSegmentIndex)!
        schoolSelectedInt = schoolPickerDictionary[schoolSelected] ?? 0
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return socialArray[schoolSelectedInt].count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return socialArray[schoolSelectedInt][section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialMediaTableCell", for: indexPath)
        cell.textLabel!.text = socialArray[schoolSelectedInt][indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appPrefix : String = headerDeepLinkPrefixes[indexPath.section]
        let safariPrefix : String = headerSafariPrefixes[indexPath.section]
        let screenName : String = socialURLArray[schoolSelectedInt][indexPath.section][indexPath.row]
        let appURL = NSURL(string: "\(appPrefix)\(screenName)")!
        let webURL = NSURL(string: "\(safariPrefix)\(screenName)")!
        
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }

}


