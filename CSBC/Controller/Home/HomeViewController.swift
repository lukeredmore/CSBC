//
//  HomeViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/28/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import PDFKit
import SafariServices
import AuthenticationServices
import Alamofire
import SwiftSoup
import UserNotifications
import RevealingSplashView

class HomeViewController: CSBCViewController , UICollectionViewDataSource, UICollectionViewDelegate, AlertDelegate {
    
    //Collection Setup Properties
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    let buttonImages : [String] = ["Today","Portal","Contact","Calendar","News","Lunch","Athletics","Give","Connect","Dress Code","Docs","Options"]
    let monthArray = ["January","February","March","April","May","June","","","September","October","November","December"]
    var columnLayout = ColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: (UIScreen.main.bounds.width)/15.88,
        minimumLineSpacing: (UIScreen.main.bounds.height-133)/15.88,
        sectionInset: UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)
    )
    
    //Alert Setup Properties
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wordmarkMarginHeightConstraint: NSLayoutConstraint!
    let gothamFont = UIFont(name: "Gotham-Bold", size: 18.0)
    @IBOutlet weak var alertBanner: UIView!
    var snowDayArrayCount : Int = 0
    
    //Document Download Properties
    var HTMLParser : HTMLController?
    
    //MARK: Notification Properties
    var localNotifications : NotificationController?
    var localAlerts : AlertController?
    let schoolsNotifications = ["showSetonNotifications","showJohnNotifications","showSaintsNotifications","showJamesNotifications"]
    
    //MARK: Other properties
    let production: Bool = Env.isProduction()
    var athleticsData = AthleticsDataParser()
    var calendarData = EventsParsing()
    let safariViewURLS : [Int:String] = [5:"https://csbcsaints.org/news",8:"https://app.mobilecause.com/form/fi0kKA?vid=hf0o"]
    var button = ""
    var groupedArray : [[[String:String]]] = [[[:]]]
    var i = 0
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        if production {
            print("Application successfully loaded in production configuration")
        } else {
            print("Application successfully loaded in debug configuration")
        }
        print("Version", appVersion)

        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "lettermark")!,iconInitialSize: CGSize(width: 128, height: 128), backgroundColor: UIColor(named: "CSBCBackground")!)
        self.view.addSubview(revealingSplashView)
        removeBannerAlert()
        
        //Document Downloader
        HTMLParser = HTMLController()
        HTMLParser?.getSpecialLunchMenuURLs()
        
        //Refresh other data
        localAlerts = AlertController(delegate: self)
        localNotifications = NotificationController()
        
        //Setup UI
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        configureCollectionViewForScreenSize()
        revealingSplashView.startAnimation()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localAlerts?.checkForAlert()
        if !production {
            localNotifications = NotificationController() //TEST
        }
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    //MARK: Alert Delegate Methods
    func reinitNotifications() {
        localNotifications?.reinit()
    }
    func showBannerAlert(withMessage : String) {
        view.backgroundColor = .csbcAlertRed
        alertBanner.backgroundColor = .csbcAlertRed
        alertLabel.text = withMessage
        let bannerHeight = ((alertLabel.text?.height(withConstrainedWidth: alertLabel.frame.width, font: gothamFont!))!) + 15.0
        alertViewHeightConstraint.constant = bannerHeight
        wordmarkMarginHeightConstraint.constant = 9.0//60
        view.layoutIfNeeded()
        alertLabel.isHidden = false
    }
    func removeBannerAlert() {
        alertLabel.text = ""
        alertViewHeightConstraint.constant = 0
        wordmarkMarginHeightConstraint.constant = 5
        view.backgroundColor = .csbcGreen
        alertBanner.backgroundColor = .csbcGreen
        alertLabel.text = ""
        view.layoutIfNeeded()
        alertLabel.isHidden = true
    }

    
    //MARK: Show SFSafariViewController
    func showSafariView(withTag : Int) {
        if let url = URL(string: safariViewURLS[withTag]!) {
            let safariView = SFSafariViewController(url: url)
            safariView.preferredBarTintColor = UIColor(named: "CSBCNavBarBackground")!
            safariView.preferredControlTintColor = UIColor(named: "CSBCNavBarText")!
            safariView.modalTransitionStyle = .coverVertical
            safariView.modalPresentationStyle = .overCurrentContext
            
            self.present(safariView, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Navigation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let tag : Int = indexPath.row + 1
        button = buttonImages[tag - 1]
        switch tag {
        case 1: //Today
            //performSegue(withIdentifier: "AlertsSegue", sender: self)
            performSegue(withIdentifier: "TodaySegue", sender: self)
        case 2: //Portal
            performSegue(withIdentifier: "WebSegue", sender: self)
        case 3: //Contact
            performSegue(withIdentifier: "ContactSegue", sender: self)
        case 4: //Calendar
            performSegue(withIdentifier: "CalendarSegue", sender: self)
        case 5: //News
            showSafariView(withTag: 5)
        case 6: //Lunch
            performSegue(withIdentifier: "LunchSegue", sender: self)
        case 7: //Athletics
            performSegue(withIdentifier: "AthleticsSegue", sender: self)
        case 8: //Give
            guard let url = URL(string: "https://app.mobilecause.com/form/fi0kKA?vid=hf0o") else { return }
            UIApplication.shared.open(url)
        //showSafariView(withTag: 8)
        case 9: //Connect
            performSegue(withIdentifier: "SocialMediaSegue", sender: self)
        case 10: //Dress Code
            performSegue(withIdentifier: "UniformsSegue", sender: self)
        case 11: //Docs
            performSegue(withIdentifier: "DocumentsSegue", sender: self)
        case 12: //Options
            performSegue(withIdentifier: "SettingsSegue", sender: self)
        default:
            break
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AthleticsSegue":
            let childVC = segue.destination as! AthleticsViewController
            childVC.athleticsData = athleticsData
        case "TodaySegue":
            let childVC = segue.destination as! TodayContainerViewController
            childVC.athleticsData = self.athleticsData
            childVC.calendarData = self.calendarData
        case "CalendarSegue":
            let childVC = segue.destination as! CalendarViewController
            childVC.calendarData = calendarData
        default:
            break
        }
    }
    
    //MARK: CollectionView Setup
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        configureCollectionViewForScreenSize()
    }
    func configureCollectionViewForScreenSize() {
        if UIDevice.current.orientation.isLandscape {
            columnLayout.cellsPerRow = 4
        } else {
            columnLayout.cellsPerRow = 3
        }
        columnLayout.minimumInteritemSpacing = (UIScreen.main.bounds.width)/9
        columnLayout.minimumLineSpacing = (UIScreen.main.bounds.height-133)/12
        if UIScreen.main.bounds.width == 1366 {
            columnLayout.minimumLineSpacing = (UIScreen.main.bounds.height-133)/9
            columnLayout.sectionInset = UIEdgeInsets(top: 35.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if UIScreen.main.bounds.width == 1112 {
            columnLayout.sectionInset = UIEdgeInsets(top: 60.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if UIScreen.main.bounds.height == 1366 {
            columnLayout.sectionInset = UIEdgeInsets(top: 20.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if view.traitCollection.horizontalSizeClass == .regular && UIDevice.current.orientation.isLandscape {
            columnLayout.sectionInset = UIEdgeInsets(top: 35.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if view.traitCollection.horizontalSizeClass == .regular {
            columnLayout.sectionInset = UIEdgeInsets(top: 30.0, left: 60.0, bottom: 30.0, right: 60.0)
        } else {
            print("Application is running on an iPhone")
            columnLayout.minimumInteritemSpacing = 0//(UIScreen.main.bounds.width)/16
            columnLayout.minimumLineSpacing = (UIScreen.main.bounds.height-133)/15.88
            columnLayout.sectionInset = UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)
        }
        //Collection View and header setup
        headerHeightConstraint.constant = ((UIScreen.main.bounds.height)/8) + 23//6.737
        collectionView?.collectionViewLayout = columnLayout
        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        let image = UIImage(named: buttonImages[indexPath.row])
        let title = buttonImages[indexPath.row]
        cell.displayContent(image: image!, title: title)
        
        return cell
    }
}
