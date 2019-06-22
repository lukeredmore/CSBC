//
//  UniformsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/14/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import WebKit

class UniformsViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet var schoolPicker: UISegmentedControl!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var loadingSymbol: UIActivityIndicatorView!
    @IBOutlet var maskView: UIView!
    
    var schoolSelected = ""
    var schoolSelectedToDisplay = 0
    weak var delegate : SchoolSelectedDelegate? = nil
    let dressCodeHTMLs = ["highSchoolDress","middleSchoolDress","elementarySchoolDress"]

    //MARK: - New school picker properties
    let schoolPickerDictionary : [String:Int] = ["Seton":0,"St. John's":1,"All Saints":2,"St. James":3]
    var schoolSelectedInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dress Code"
        webView.navigationDelegate = self
        loadingSymbol.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingSymbol.style = .large
        } else {
            loadingSymbol.style = .whiteLarge
            loadingSymbol.color = .gray
        }
        if #available(iOS 13.0, *) {
            schoolPicker.overrideUserInterfaceStyle = .dark
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        maskView.isHidden = false
        loadingSymbol.startAnimating()
        schoolSelectedInt = schoolPickerDictionary[schoolSelected] ?? 0
        if schoolSelectedInt > 0 {
            schoolSelectedToDisplay = 2
        } else {
            schoolSelectedToDisplay = schoolSelectedInt
        }
        schoolPicker.selectedSegmentIndex = schoolSelectedToDisplay
        updateDressCodeShown()
    }
    override func viewWillDisappear(_ animated: Bool) {
//        var schoolToPassBack : Int
//        if schoolSelectedToDisplay > 1 {
//            schoolToPassBack = schoolSelectedInt
//        } else {
//            schoolToPassBack = 0
//        }
        delegate?.storeSchoolSelected(schoolSelected: schoolSelected)
    }
    
    @IBAction func schoolPickerValueChanged(_ sender: Any) {
        schoolSelectedToDisplay = schoolPicker.selectedSegmentIndex
        updateDressCodeShown()
    }
    
    func updateDressCodeShown() {
        var isDark = ""
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                isDark = "Dark"
            }
        }
        let url = Bundle.main.url(forResource: "\(dressCodeHTMLs[schoolSelectedToDisplay])\(isDark)", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        //let url = URL(string: "https://csbcsaints.org/calendar")
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
