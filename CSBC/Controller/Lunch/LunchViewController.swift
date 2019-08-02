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
    @IBOutlet weak var webView: WKWebView!
    
    var dateLabelText : String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return "Today is \(formatter.string(from: Date()))"
    }
    var loadedPDFURLs : [Int:URL] {
        return UserDefaults.standard.object([Int:URL].self, with: "PDFLocations")!
    }
    var loadedWordURLs : [Int:String] {
        return UserDefaults.standard.object([Int:String].self, with: "WordLocations")!
    }
    
    
    //MARK: ViewControl
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        webView.navigationDelegate = self
        dateLabel.text = dateLabelText
    }
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [webView, pdfView])
        super.viewWillAppear(animated)
    }
    
    
    //MARK: Lunch Menu Displayed Methods
    override func schoolPickerValueChanged(_ sender: CSBCSegmentedControl) {
        super.schoolPickerValueChanged(sender)
        reloadDocumentView()
    }
    @objc func reloadDocumentView() {
        loadingSymbol.startAnimating()
        webView.isHidden = true
        pdfView.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        if let pdfToDisplay = loadedPDFURLs[schoolSelected.ssInt] {
            configurePDFView(forPDF: PDFDocument(url: pdfToDisplay))
        } else if let docURLToDisplay = loadedWordURLs[schoolSelected.ssInt] {
            configureWebView(forDocURLString: docURLToDisplay)
        }
    }
    func configurePDFView(forPDF pdf : PDFDocument?) {
        pdfView.document = pdf
        pdfView.displayMode = .singlePageContinuous
        let pdfScale = pdfView.scaleFactorForSizeToFit - 0.02
        pdfView.autoScales = true
        pdfView.scaleFactor = pdfScale
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = pdfScale
        pdfView.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = true
        loadingSymbol.stopAnimating()
    }
    func configureWebView(forDocURLString url : String) {
        if let urlToLoad = URL(string: "https://docs.google.com/gview?url=\(url)") {
            let urlToRequest = URLRequest(url: urlToLoad)
            webView.load(urlToRequest)
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
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = !UIDevice.current.orientation.isLandscape
        }
    }
    @objc func canRotate() -> Void {}
    
    
    //MARK: WebView Methods
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loadingSymbol.startAnimating()
        webView.isHidden = true
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingSymbol.stopAnimating()
        webView.isHidden = false
    }
}
