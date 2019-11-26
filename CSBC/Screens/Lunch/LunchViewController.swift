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
    @IBOutlet weak private var pdfView: PDFView!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var webView: WKWebView! {
        didSet { webView.navigationDelegate = self }
    }
    
    private var selectedPDFURL : URL? {
        var loadedURLs : [Int:URL] {
            return UserDefaults.standard.object([Int:URL].self, with: "LunchURLs") ?? [:]
        }
        if let pdfURL = loadedURLs[schoolSelected.rawValue] {
            return pdfURL
        } else if loadedURLs[Schools.john.rawValue] != nil && schoolSelected == .james {
            return loadedURLs[Schools.john.rawValue]
        } else if let docURLToDisplay = loadedURLs[schoolSelected.rawValue] {
            return docURLToDisplay
        }
        return nil
    }
    
    private var dateLabelText : String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return "Today is \(formatter.string(from: Date()))"
    }
    
    
    //MARK: ViewControl
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        dateLabel.text = dateLabelText
    }
    override func viewWillAppear(_ animated: Bool) {
        setupSchoolPickerAndBarForDefaultBehavior(topMostItems: [webView, pdfView])
        super.viewWillAppear(animated)
    }
    
    
    //MARK: Lunch Menu Displayed Methods
    override func schoolPickerValueChanged() {
        reloadDocumentView(withURL: selectedPDFURL)
    }
    private func reloadDocumentView(withURL url : URL?) {
        startLoading()
        guard let url = url else { return }
        
        if url.absoluteString.components(separatedBy: ".").last == "pdf" {
            configurePDFView(forPDF: PDFDocument(url: url))
        } else {
            configureWebView(forDocURLString: url.absoluteString)
        }
    }
    private func startLoading() {
        loadingSymbol.startAnimating()
        webView.isHidden = true
        pdfView.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    private func finishLoading() {
        if pdfView.document != nil {
            pdfView.isHidden = false
        } else {
            webView.isHidden = false
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
        loadingSymbol.stopAnimating()
    }
    private func configurePDFView(forPDF pdf : PDFDocument?) {
        pdfView.document = pdf
        pdfView.displayMode = .singlePageContinuous
        let pdfScale = pdfView.scaleFactorForSizeToFit - 0.02
        pdfView.autoScales = true
        pdfView.scaleFactor = pdfScale
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = pdfScale
        finishLoading()
    }
    private func configureWebView(forDocURLString url : String) {
        if let urlToLoad = URL(string: "https://docs.google.com/gview?url=\(url)") {
            let urlToRequest = URLRequest(url: urlToLoad)
            startLoading()
            pdfView.document = nil
            webView.load(urlToRequest)
        }
    }
    @objc private func shareButtonPressed() {
        guard loadingSymbol.isHidden else { return }
        let activityViewController = UIActivityViewController(activityItems: [selectedPDFURL!], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Rotational functions
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if isMovingFromParent {
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
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { finishLoading() }
}
