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
final class HomeViewController: CSBCViewController, SegueDelegate {
    private lazy var mainView = HomeView(segueDelegate: self)
    private lazy var alertController = AlertController(alertDelegate: mainView)
    private var navBarShouldAppearWhileTransitioning = true
    var lastSeguedWebView: WebViewController?
    

    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        StaticData.getDataFromFirebase() {
            self.mainView.rebuild()
        }
        self.view = mainView
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertController.checkForAlert()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(!navBarShouldAppearWhileTransitioning, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mainView.rebuild()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WebSegue" {
            lastSeguedWebView = segue.destination as? WebViewController
        } else if segue.identifier == "CovidSegue" {
            let vc = segue.destination as? CovidViewController
            vc?.delegate = self
        }
        
    }
    
    func modalHoverViewTapped() {
        let web = SFSafariViewController(url: URL(string: "https://www.csbcsaints.org/covid")!)
        web.preferredBarTintColor = .csbcSafariVCBar
        web.preferredControlTintColor = .csbcNavBarText
        web.modalTransitionStyle = .coverVertical
        web.modalPresentationStyle = .overCurrentContext
        present(web, animated: true)
        /*STEM NIGHT
        guard #available(iOS 13.0, *) else {
            alert("Not supported", message: "Please upgrade to iOS 13 to access exclusive STEM Night features.")
            return
        }
        navBarShouldAppearWhileTransitioning = false
        present(STEMNavigationController(), animated: true) { self.navBarShouldAppearWhileTransitioning = true }
        */
    }
    
}

extension HomeViewController: CovidDelegate {
    func questionaireCompleted() {
        alert("Questionnaire complete!", message: "Thank you for completing the check-in. If any of your answers change throughout the day/week, please fill out this form again.")
    }
}
