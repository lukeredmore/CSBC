//
//  NewsViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 9/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import WebKit

class NewsViewController: CSBCViewController, WKNavigationDelegate {
    @IBOutlet private var webView : WKWebView! { didSet {
           webView.configuration.preferences.javaScriptEnabled = true
           webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
           webView.navigationDelegate = self
       } }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: URL(string: "https://www.csbcsaints.org/news")!)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingSymbol.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingSymbol.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.absoluteString.contains("csbcsaints.org") ?? false {
            decisionHandler(WKNavigationActionPolicy.allow)
        } else {
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
    }
}
