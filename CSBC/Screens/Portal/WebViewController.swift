//
//  WebViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/8/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import WebKit

/// Loads PlusPortals in WKWebView with custom controls and ability to select school
class WebViewController: CSBCViewController, WKNavigationDelegate {
    
    private var portalURLStrings = ["setoncchs", "setoncchs", "SCASS", "StJamesMS"]
    @IBOutlet private var webView: WKWebView!
    @IBOutlet weak private var myProgressView: UIProgressView!
    private var compileDate : Date {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        { return infoDate }
        return Date()
    }
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .csbcNavBarBackground
        if Date() < compileDate + 345600 {
            print("This date is too early")
            portalURLStrings = ["setoncchs", "setoncchs", "setoncchs", "setoncchs"]
        }
        self.title = "Portal"
        myProgressView.trackTintColor = .csbcYellow
        
        webView.navigationDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [myProgressView], barHeight: 5)
        super.viewWillAppear(animated)
    }
    override func schoolPickerValueChanged() {
        if let urlToLoad = URL(string: "https://plusportals.com/\(portalURLStrings[schoolSelected.rawValue])") {
            let urlToRequest = URLRequest(url: urlToLoad)
            webView.load(urlToRequest)
        }
    }
    
    
    //MARK: WebView Delegate Methods
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
    
    
    //MARK: Custom WebView Action Buttons
    @objc private func removeProgressBar() {
        myProgressView.progressTintColor = .csbcYellow
    }
    @IBAction private func backButtonPressed(_ sender: Any) {
        webView.goBack()
    }
    @IBAction private func forwardButtonPressed(_ sender: Any) {
        webView.goForward()
    }
    @IBAction private func refreshButtonPressed(_ sender: Any) {
        webView.reload()
        myProgressView.setProgress(0.0, animated: false)
        myProgressView.progressTintColor = .blue
    }
}
