//
//  WebViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/8/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var schoolSelected = ""
    var urlToLoadOnViewWillAppear = 0
    private var progressKVOhandle: NSKeyValueObservation?
    weak var delegate : SchoolSelectedDelegate? = nil
    var portalURLStrings = ["setoncchs", "setoncchs", "SCASS", "StJamesMS"]
    @IBOutlet var webView: WKWebView!
    @IBOutlet var schoolPicker: UISegmentedControl!
    @IBOutlet weak var myProgressView: UIProgressView!
    var compileDate : Date
    {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        { return infoDate }
        return Date()
    }
    
    //MARK: - New school picker properties
    let schoolPickerDictionary : [String:Int] = ["Seton":0,"St. John's":1,"All Saints":2,"St. James":3]
    var editedSchoolNames : [String] = []
    var schoolSelectedInt = 0
    @IBOutlet weak var schoolPickerHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .csbcGreen
        if Date() < compileDate + 345600 {
            print("This date is too early")
            portalURLStrings = ["setoncchs", "setoncchs", "setoncchs", "setoncchs"]
        }
        self.title = "Portal"
        webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myProgressView.setProgress(0.0, animated: false)
        myProgressView.progressTintColor = UIColor.blue
        shouldIShowAllSchools(schoolPicker: schoolPicker, schoolPickerHeightConstraint: schoolPickerHeightConstraint)
        schoolSelectedInt = schoolPickerDictionary[schoolSelected] ?? 0
        for i in 0..<schoolPicker.numberOfSegments {
            if schoolPicker.titleForSegment(at: i) == schoolSelected {
                schoolPicker.selectedSegmentIndex = i
            }
        }
        
        let urlToLoad = URL(string: "https://plusportals.com/\(portalURLStrings[schoolSelectedInt])")
        let urlToRequest = URLRequest(url: urlToLoad!)
        webView.load(urlToRequest)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.storeSchoolSelected(schoolSelected: schoolPicker.titleForSegment(at: schoolPicker.selectedSegmentIndex) ?? "Seton")
    }
    
    @IBAction func schoolPickerValueChanged(_ sender: Any) {
        schoolSelected = schoolPicker.titleForSegment(at: schoolPicker.selectedSegmentIndex)!
        schoolSelectedInt = schoolPickerDictionary[schoolSelected] ?? 0
        
        let urlToLoad = URL(string: "https://plusportals.com/\(portalURLStrings[schoolSelectedInt])")
        let urlToRequest = URLRequest(url: urlToLoad!)
        webView.load(urlToRequest)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        myProgressView.progressTintColor = .csbcYellow
        myProgressView.setProgress(0.0, animated: false)
        myProgressView.progressTintColor = .blue
        myProgressView.setProgress(0.1, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.myProgressView.setProgress(1.0, animated: true)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(removeProgressBar), userInfo: nil, repeats: false)
    }
    
    @objc func removeProgressBar() {
        myProgressView.progressTintColor = .csbcYellow
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        webView.goBack()
    }
    
    
    @IBAction func forwardButtonPressed(_ sender: Any) {
        webView.goForward()
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        webView.reload()
        myProgressView.setProgress(0.0, animated: false)
        myProgressView.progressTintColor = .blue
    }

}
