//
//  CovidViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 7/30/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import WebKit

protocol CovidDelegate: class {
    func questionaireCompleted()
}

class CovidViewController: CSBCViewController {
    
    static var showCovidCheckIn : Bool {
        get {
            #if DEBUG
            return true
            #else
            return Bool(StaticData.readData(atPath: "general/showCovidCheckIn") ?? "false") ?? false
            #endif
        }
    }
    
    var delegate : CovidDelegate? = nil
    
    @IBOutlet weak var covidText: UILabel! {
        didSet {
            covidText.text = "The Catholic Schools of Broome County are working hard to maintain the safety and health of our students, faculty, staff and families. In order to ensure everyone’s safety we are asking that faculty and staff use the check-in below each day, and for families to check-in weekly.\n\nIn addition, we will be taking temperature checks of everyone who enters a CSBC building daily. Thank you in advance for your cooperation."
        }
    }
    @IBOutlet weak var staffQuestionnaireWebView: WKWebView! {
        didSet {
            staffQuestionnaireWebView.navigationDelegate = self
            staffQuestionnaireWebView.scrollView.showsHorizontalScrollIndicator = false
            staffQuestionnaireWebView.scrollView.alwaysBounceVertical = true
            staffQuestionnaireWebView.scrollView.maximumZoomScale = 1.0
            staffQuestionnaireWebView.scrollView.minimumZoomScale = 1.0
            staffQuestionnaireWebView.scrollView.delegate = self
        }
    }
    @IBOutlet weak var familyQuestionnaireWebView: WKWebView!{
        didSet {
            familyQuestionnaireWebView.navigationDelegate = self
            familyQuestionnaireWebView.scrollView.showsHorizontalScrollIndicator = false
            familyQuestionnaireWebView.scrollView.alwaysBounceVertical = true
            familyQuestionnaireWebView.scrollView.maximumZoomScale = 1.0
            familyQuestionnaireWebView.scrollView.minimumZoomScale = 1.0
            familyQuestionnaireWebView.scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var landingPageContainerView: UIView!
    
    
    @IBOutlet weak var staffQuestionnaireButton: ButtonWithActivityIndicator! {
        didSet {
            staffQuestionnaireButton.layer.cornerRadius = 55.0/2
        }
    }
    @IBOutlet weak var familyQuestionnaireButton: ButtonWithActivityIndicator! {
        didSet {
            familyQuestionnaireButton.layer.cornerRadius = 55.0/2
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        resetWebViews()
    }
    
    private func resetWebViews() {
        staffQuestionnaireButton.loading(true)
        familyQuestionnaireButton.loading(true)
        staffQuestionnaireWebView.load(URLRequest(url: URL(string: "https://app.mobilecause.com/form/JhGAZQ")!))
        familyQuestionnaireWebView.load(URLRequest(url: URL(string: "https://app.mobilecause.com/form/s1lTAQ")!))
        staffQuestionnaireWebView.isHidden = true
        familyQuestionnaireWebView.isHidden = true
        landingPageContainerView.isHidden = false
    }
    
    @IBAction func staffQuestionnaireButtonPressed(_ sender: Any) {
        familyQuestionnaireWebView.isHidden = true
        staffQuestionnaireWebView.show() {
            self.landingPageContainerView.isHidden = true
        }
    }
    
    @IBAction func familyQuestionnaireButtonPressed(_ sender: Any) {
        staffQuestionnaireWebView.isHidden = true
        familyQuestionnaireWebView.show() {
            self.landingPageContainerView.isHidden = true
        }
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}


extension CovidViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if (webView.url!.absoluteString.contains("confirmation")) {
            staffQuestionnaireWebView.isHidden = true
            familyQuestionnaireWebView.isHidden = true
            self.dismiss(animated: true) {
                self.delegate?.questionaireCompleted()
            }
        } else if (webView.url!.absoluteString.contains("/form/JhGAZQ")) {
            staffQuestionnaireButton.loading(false)
        } else if (webView.url!.absoluteString.contains("/form/s1lTAQ")) {
            familyQuestionnaireButton.loading(false)
        }
    }
}

extension CovidViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x > 0) {
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
        }
    }
}

extension WKWebView {
    func show(completion: (() -> Void)? = nil) {
        self.layer.zPosition = CGFloat.greatestFiniteMagnitude
        let ogFrame = self.frame
        self.frame = CGRect(x: self.frame.origin.x, y: UIScreen.main.bounds.height, width: self.frame.width, height: self.frame.height)
        self.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.frame = ogFrame
        }) { animated in
            completion?()
        }
    }
}
