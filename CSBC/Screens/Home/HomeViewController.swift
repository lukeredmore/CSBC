//
//  HomeViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/28/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

/// Initial VC, segues into main screens of app, handles and displays critical alert methods
final class HomeViewController: CSBCViewController, SegueDelegate {
    private lazy var mainView = HomeView(segueDelegate: self)
    private lazy var alertController = AlertController(alertDelegate: mainView)
    
    var lastSeguedWebView: WebViewController?
    

    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = mainView
        CSBCSplashView(addToView: view).startAnimation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertController.checkForAlert()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mainView.rebuild()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WebSegue" { lastSeguedWebView = segue.destination as? WebViewController }
    }
    
}
