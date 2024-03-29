//
//  SocialMediaController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/18/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit


///All methods, delegates and data for Connect view
class SocialMediaController: CSBCViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableHeaders = ["Twitter", "Facebook", "Instagram"]
    private let headerDeepLinkPrefixes = ["twitter://user?screen_name=", "fb://profile/", "instagram://user?username="]
    private let headerSafariPrefixes = ["https://twitter.com/", "https://facebook.com/", "https://instagram.com/"]
    private let socialArray = [
        [ //Seton
            ["Catholic Schools of Broome County", "Dr. Elizabeth Carter, President", "Seton Catholic Central", "Matthew Martinkovic, Principal", "SCC Student Council", "SCC Key Club", "SCC Fan Club", "SCC Junior Fan Club"], //t
            ["Catholic Schools of Broome County", "Seton Catholic Central", "SCC Junior Fan Club"], //f
            ["SCC Junior Fan Club"] //i
        ],[ //St. John's
            ["Catholic Schools of Broome County", "Dr. Elizabeth Carter, President", "St. John School"], //t
            ["Catholic Schools of Broome County", "St. John School"] //f
        ],[ //All Saints
            ["Catholic Schools of Broome County", "Dr. Elizabeth Carter, President", "William Pipher, Principal"], // t
            ["Catholic Schools of Broome County", "All Saints School"] //f
        ],[ //St. James
            ["Catholic Schools of Broome County", "Dr. Elizabeth Carter, President", "St. James School"], //t
            ["Catholic Schools of Broome County", "St. James School"], //f
            ["St. James School", "Principal"] //i
        ]
    ]
    private let socialURLArray = [
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
            ["CatholicSchools", "CatholicSchPres", "StJamesSchoolJC"], //t
            ["103950839670987", "136066559773647"], //f
            ["stjamesschooljc", "stjamesjcprincipal"] //i
        ]
    ]
    private var selectedSocial : [[String]] = [[]]
    private var selectedSocialURL : [[String]] = [[]]
    @IBOutlet private var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Connect"
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [tableView])
        super.viewWillAppear(animated)
    }
    override func schoolPickerValueChanged() {
        tableView.reloadData()
    }
    
    
    //MARK: TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return socialArray[schoolSelected.rawValue].count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialArray[schoolSelected.rawValue][section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialMediaTableCell", for: indexPath)
        cell.textLabel!.text = socialArray[schoolSelected.rawValue][indexPath.section][indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableHeaders[section]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appPrefix : String = headerDeepLinkPrefixes[indexPath.section]
        let safariPrefix : String = headerSafariPrefixes[indexPath.section]
        let screenName : String = socialURLArray[schoolSelected.rawValue][indexPath.section][indexPath.row]
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


