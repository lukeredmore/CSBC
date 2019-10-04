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
    @IBOutlet private var webView: WKWebView! { didSet {
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView.navigationDelegate = self
    } }
    @IBOutlet weak private var myProgressView: UIProgressView!
    private var portalURLStrings : [String] {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let compileDate = infoAttr[FileAttributeKey.creationDate] as? Date,
            Date() < compileDate + 345600 {
            print("This date is too early, returning dummy URLs")
            return ["setoncchs", "setoncchs", "setoncchs", "setoncchs"]
        } else {
            return ["setoncchs", "SJS", "SCASS", "StJamesMS"]
        }
    }
    private var linkLoaded = false
    
    //MARK: View Control
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [myProgressView], barHeight: 5)
        if linkLoaded == false {
            super.viewWillAppear(animated)
        }
    }
    override func schoolPickerValueChanged() {
        if let urlToLoad = URL(string: "https://plusportals.com/\(portalURLStrings[schoolSelected.rawValue])") {
            let urlToRequest = URLRequest(url: urlToLoad)
            webView.load(urlToRequest)
            linkLoaded = true
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
        myProgressView.setProgress(1.0, animated: true)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(removeProgressBar), userInfo: nil, repeats: false)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        navigationAction.request.url?.absoluteString.lowercased().contains("plusportals.com") ?? false ? decisionHandler(WKNavigationActionPolicy.allow) : decisionHandler(WKNavigationActionPolicy.cancel)
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
    }
}
