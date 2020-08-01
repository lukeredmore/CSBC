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
    
    var delegate : CovidDelegate? = nil
    
    @IBOutlet weak var covidText: UILabel! {
        didSet {
            covidText.text = "The Catholic Schools of Broome County are working hard to maintain the safety and health of our students, faculty, staff and families. In order to ensure everyone’s safety we are asking that faculty and staff use the check-in below each day, and for families to check-in weekly.\n\nIn addition, we will be taking temperature checks of everyone who enters a CSBC building daily. Thank you in advance for your cooperation."
        }
    }
    @IBOutlet weak var staffQuestionaireWebView: WKWebView! {
        didSet {
            staffQuestionaireWebView.navigationDelegate = self
            staffQuestionaireWebView.scrollView.showsHorizontalScrollIndicator = false
            staffQuestionaireWebView.scrollView.alwaysBounceVertical = true
            staffQuestionaireWebView.scrollView.maximumZoomScale = 1.0
            staffQuestionaireWebView.scrollView.minimumZoomScale = 1.0
            staffQuestionaireWebView.scrollView.delegate = self
        }
    }
    @IBOutlet weak var familyQuestionaireWebView: WKWebView!{
        didSet {
            familyQuestionaireWebView.navigationDelegate = self
            familyQuestionaireWebView.scrollView.showsHorizontalScrollIndicator = false
            familyQuestionaireWebView.scrollView.alwaysBounceVertical = true
            familyQuestionaireWebView.scrollView.maximumZoomScale = 1.0
            familyQuestionaireWebView.scrollView.minimumZoomScale = 1.0
            familyQuestionaireWebView.scrollView.delegate = self
        }
    }
    
    @IBOutlet weak var landingPageContainerView: UIView!
    
    
    @IBOutlet weak var staffQuestionaireButton: ButtonWithActivityIndicator! {
        didSet {
            staffQuestionaireButton.layer.cornerRadius = 55.0/2
        }
    }
    @IBOutlet weak var familyQuestionaireButton: ButtonWithActivityIndicator! {
        didSet {
            familyQuestionaireButton.layer.cornerRadius = 55.0/2
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        resetWebViews()
    }
    
    private func resetWebViews() {
        staffQuestionaireButton.loading(true)
        familyQuestionaireButton.loading(true)
        staffQuestionaireWebView.load(URLRequest(url: URL(string: "https://app.mobilecause.com/form/JhGAZQ")!))
        familyQuestionaireWebView.load(URLRequest(url: URL(string: "https://app.mobilecause.com/form/s1lTAQ")!))
        staffQuestionaireWebView.isHidden = true
        familyQuestionaireWebView.isHidden = true
        landingPageContainerView.isHidden = false
    }
    
    @IBAction func staffQuestionaireButtonPressed(_ sender: Any) {
        familyQuestionaireWebView.isHidden = true
        staffQuestionaireWebView.show() {
            self.landingPageContainerView.isHidden = true
        }
    }
    
    @IBAction func familyQuestionaireButtonPressed(_ sender: Any) {
        staffQuestionaireWebView.isHidden = true
        familyQuestionaireWebView.show() {
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
            staffQuestionaireWebView.isHidden = true
            familyQuestionaireWebView.isHidden = true
            self.dismiss(animated: true) {
                self.delegate?.questionaireCompleted()
            }
        } else if (webView.url!.absoluteString.contains("/form/JhGAZQ")) {
            staffQuestionaireButton.loading(false)
        } else if (webView.url!.absoluteString.contains("/form/s1lTAQ")) {
            familyQuestionaireButton.loading(false)
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
