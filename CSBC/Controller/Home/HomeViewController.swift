//
//  HomeViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/28/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import SafariServices

/// Initial VC, segues into main screens of app, handles and displays critical alert methods
class HomeViewController: CSBCViewController, AlertDelegate {
    
    //Collection Setup Properties
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    let collectionController = HomeCollectionViewDataSource()
    
    //Alert Setup Properties
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wordmarkMarginHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertBanner: UIView!
    var localAlerts : AlertController?
    
    //Other properties
    var athleticsData = AthleticsDataParser()
    var calendarData = EventsDataParser()

    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        if Env.isProduction() {
            print("Application successfully loaded in production configuration")
        } else {
            print("Application successfully loaded in debug configuration")
        }
        print("Version " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))
        
        localAlerts = AlertController(self)
        
        //Setup CollectionView
        collectionView.delegate = collectionController
        collectionView.dataSource = collectionController
        collectionController.configureCollectionViewForScreenSize(self)
        
        let splashView = CSBCSplashView(addToView: view)
        splashView.startAnimation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localAlerts?.checkForAlert()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionController.configureCollectionViewForScreenSize(self)
    }
    
    
    //MARK: Alert Delegate Methods
    func reinitNotifications() {
        let localNotifications = NotificationController()
        localNotifications.subscribeToTopics()
        localNotifications.queueNotifications()
    }
    func showBannerAlert(withMessage alertText: String) {
        view.backgroundColor = .csbcAlertRed
        alertBanner.backgroundColor = .csbcAlertRed
        alertLabel.text = alertText
        let bannerHeight = ((alertLabel.text?.height(withConstrainedWidth: alertLabel.frame.width, font: UIFont(name: "Gotham-Bold", size: 18.0)!))!) + 15.0
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
        view.layoutIfNeeded()
        alertLabel.isHidden = true
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AthleticsSegue":
            let childVC = segue.destination as! AthleticsViewController
            childVC.athleticsData = self.athleticsData
        case "TodaySegue":
            let childVC = segue.destination as! TodayContainerViewController
            childVC.athleticsData = self.athleticsData
            childVC.calendarData = self.calendarData
        default:
            break
        }
    }
    func showNewsInSafariView() {
        if let url = URL(string: "https://csbcsaints.org/news") {
            let safariView = SFSafariViewController(url: url)
            safariView.configureForCSBC()
            self.present(safariView, animated: true, completion: nil)
        }
        
    }
}
