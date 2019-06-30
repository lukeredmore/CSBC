//
//  ContactParallaxViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/23/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import MessageUI

class ContactParallaxViewController: CSBCViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var copyrightLabel: UILabel!
    let imageView = UIImageView()
    var headerImage: UIImage!
    var yearFormatter : DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy"
        return fmt
    }
    
    //Mark: Table Data
    let sectionHeaders = ["Map","Contact","Hours of Operation"]
    let mapImageArray = ["setonMap","saintsMap","saintsMap","jamesMap"]
    let buildingImageArray = ["setonBuilding","johnBuilding","saintsBuilding","jamesBuilding"]
    let schoolNames = ["Seton Catholic Central", "St. John the Evangelist", "All Saints School", "St. James School"]
    let schoolAddresses = ["70 Seminary Avenue Binghamton, NY 13905", "9 Livingston Street Binghamton NY 13903", "1112 Broad Street Endicott NY 13760", "143 Main Street Johnson City NY 13790"]
    let schoolPhone : [[String]] = [["723.5307", "723.4811"],["723.0703","772.6210"],["748.7423"],["797.5444"]]
    let districtPhone = "723.1547"
    let schoolPrincipals = ["Matthew Martinkovic", "James Fountaine", "Angela Tierno-Sherwood", "Susan Kitchen"]
    let principalEmails = ["mmartinkovic","jfountaine","atierno","skitchen"]
    let hoursOfOperation = [
        ["Morning Bell: 8:13 AM", "Dismissal: 3:00 PM"],
        ["Before School Care: From 7:00 AM","Start: 8:30 AM","Dismissal: 2:45 PM","After School Care: Until 5:45 PM"],
        ["Before School Care: From 7:00 AM","Start: 8:20 AM","Dismissal: 2:45 PM","After School Care: Until 6:00 PM"],
        ["Before School Care: From 7:00 AM","Start: 8:20 AM","Dismissal: 3:00 PM","After School Care: Until 6:00 PM"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentYear = yearFormatter.string(from: Date())
        copyrightLabel.text = "© \(currentYear) Catholic Schools of Broome County"
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
    }
    
    func schoolPickerValueDidChange(){
        schoolSelected = getSchoolSelected()
        updateContactUI()
        
    }
    func performSegueFromContainer(identifier : String) {
        let masterVC = parent as! ContactContainerViewController
        masterVC.performSegue(withIdentifier: identifier, sender: masterVC)
    }
    
    func updateContactUI() {
        headerImage = UIImage(named: buildingImageArray[schoolSelected.ssInt])!
        let imageHeight = (34*UIScreen.main.bounds.size.width)/69
        tableView.contentInset = UIEdgeInsets(top: imageHeight, left: 0, bottom: 0, right: 0)
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: imageHeight)
        imageView.image = headerImage
        imageView.clipsToBounds = true
        tableView.contentOffset.y += 1/3
        tableView.reloadData()
        
    }
    
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            performSegueFromContainer(identifier: "showMapSegue")
        } else if schoolPhone[schoolSelected.ssInt].count == 2 && indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                UIApplication.shared.open(URL(string: "tel://607.\(schoolPhone[schoolSelected.ssInt][0])")!)
            case 1:
                UIApplication.shared.open(URL(string: "tel://607.\(districtPhone)")!)
            case 2:
                UIApplication.shared.open(URL(string: "tel://607.\(schoolPhone[schoolSelected.ssInt][1])")!)
            case 3:
                presentMailVC()
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
                presentMailVC()
            default:
                break
            }
        }
    }
    
    //Mark: Send email
    func presentMailVC() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["\(principalEmails[schoolSelected.ssInt])@syrdiocese.org"])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send email. Please check your email configuration and try again.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        sendMailErrorAlert.addAction(okButton)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = -scrollView.contentOffset.y
        //let height = min(max(y, 60), 400)
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: y)
        
    }
    

}
