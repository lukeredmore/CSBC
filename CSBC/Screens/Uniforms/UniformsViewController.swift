//
//  UniformsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/14/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import WebKit

/// Picks dress code html file to load and shows it in a web view
class UniformsViewController: CSBCViewController, WKNavigationDelegate {

    @IBOutlet private var differentSchoolPicker: UISegmentedControl!
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var maskView: UIView!
    
    private var schoolSelectedToDisplay = 0
    private let dressCodeHTMLs = ["highSchoolDress","middleSchoolDress","elementarySchoolDress"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dress Code"
        webView.navigationDelegate = self
        if #available(iOS 13.0, *) {
            differentSchoolPicker.overrideUserInterfaceStyle = .dark
        }
        // Do any additional setup after loading the view.
        
        //setupSchoolPickerForDefaultBehavior(currentTopMostItem: schoolPicker)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        maskView.isHidden = false
        loadingSymbol.startAnimating()
        if schoolSelected.ssInt > 0 {
            schoolSelectedToDisplay = 2
        } else {
            schoolSelectedToDisplay = schoolSelected.ssInt
        }
        differentSchoolPicker.selectedSegmentIndex = schoolSelected.ssInt
        updateDressCodeShown()
    }
    override func viewWillDisappear(_ animated: Bool) {
        schoolSelected.update(differentSchoolPicker)
    }
    
    @IBAction private func schoolPickerValueChanged(_ sender: Any) {
        schoolSelectedToDisplay = differentSchoolPicker.selectedSegmentIndex
        updateDressCodeShown()
    }
    private func updateDressCodeShown() {
        var isDark = ""
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                isDark = "Dark"
            }
        }
        let url = Bundle.main.url(forResource: "\(dressCodeHTMLs[schoolSelectedToDisplay])\(isDark)", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        //private let url = URL(string: "https://csbcsaints.org/calendar")
        let urlToRequest = URLRequest(url: url)
        webView.load(urlToRequest)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        maskView.isHidden = true
        loadingSymbol.stopAnimating()
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.minimumZoomScale = 1.0
    }

}
