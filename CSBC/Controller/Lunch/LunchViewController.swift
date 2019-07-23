//
//  LunchViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/25/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import PDFKit
import WebKit

///Displays the lunch menu for a given school in either Google Drive Viewer through a WKWebView or through a PDFView, based on what information is supplied to the VC on init
class LunchViewController: CSBCViewController, WKNavigationDelegate {
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var loadingSymbol: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    var loadedPDFURLs : [Int:URL] = [:]
    var loadedWordURLs : [Int:String] = [:]
    
    
    //MARK: ViewControl
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lunch"
        view.backgroundColor = .csbcSuperLightGray
        loadingSymbol.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingSymbol.style = .large
        } else {
            loadingSymbol.style = .whiteLarge
            loadingSymbol.color = .gray
        }
        webView.navigationDelegate = self
        
        loadedPDFURLs = UserDefaults.standard.object([Int:URL].self, with: "PDFLocations")!
        loadedWordURLs = UserDefaults.standard.object([Int:String].self, with: "WordLocations")!
        print(loadedPDFURLs)
        print(loadedWordURLs)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [webView, pdfView])
        loadingSymbol.startAnimating()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        dateLabel.text = "Today is \(formatter.string(from: Date()))"
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(reloadPDFView), userInfo: nil, repeats: false)
        reloadPDFView()
    }
    
    
    //MARK: Lunch Menu Displayed Methods
    override func schoolPickerValueChanged(_ sender: CSBCSegmentedControl) {
        super.schoolPickerValueChanged(sender)
        reloadPDFView()
    }
    @objc func reloadPDFView() {
        loadingSymbol.startAnimating()
        if loadedPDFURLs[schoolSelected.ssInt] != nil {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            webView.isHidden = true
            pdfView.isHidden = false
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
            pdfView.document = PDFDocument(url: loadedPDFURLs[schoolSelected.ssInt]!)
            let defaultScale = pdfView.scaleFactorForSizeToFit - 0.02
            pdfView.scaleFactor = defaultScale
            pdfView.maxScaleFactor = 4.0
            pdfView.minScaleFactor = defaultScale
            loadingSymbol.stopAnimating()
        } else if loadedWordURLs[schoolSelected.ssInt] != nil {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            pdfView.isHidden = true
            //print(loadedMSWords[schoolSelectedInt])
            if let urlToLoad = URL(string: "https://docs.google.com/gview?url=\(loadedWordURLs[schoolSelected.ssInt]!)") {
                let urlToRequest = URLRequest(url: urlToLoad)
                webView.isHidden = false
                webView.load(urlToRequest)
            } else {
                print("The url could not be loaded")
                loadingSymbol.startAnimating()
            }
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            print("No data found for this lunch")
            pdfView.isHidden = true
            webView.isHidden = true
            loadingSymbol.startAnimating()
        }
    }
    @objc func shareButtonPressed() {
        if loadedPDFURLs[schoolSelected.ssInt] != nil && loadingSymbol.isHidden == true {
            let activityViewController = UIActivityViewController(activityItems: [PDFDocument(url: loadedPDFURLs[schoolSelected.ssInt]!)?.documentURL! as Any], applicationActivities: nil)
            DispatchQueue.main.async {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK: Rotational functions
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            if UIDevice.current.orientation.isLandscape {
                //print("You went from Portrait to Landscape")
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            } else {
                //print("You went from Landscape to Portrait")
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            }
        }
    }
    @objc func canRotate() -> Void {}
    
    
    //MARK: WebView Methods
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loadingSymbol.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingSymbol.stopAnimating()
    }
}
