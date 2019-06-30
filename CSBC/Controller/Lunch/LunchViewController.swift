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


class LunchViewController: CSBCViewController, WKNavigationDelegate {
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet var schoolPicker: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var loadingSymbol: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    var loadedPDFURLs : [Int:URL] = [:]
    var loadedWordURLs : [Int:String] = [:]
    
    let formatter = DateFormatter()
    let date = Date()
    
//    var loadedDocs : [Int:PDFDocument] = UserDefaults.standard.dictionary(forKey: "PDFLocations")
//    //Userdefaults
//    var loadedMSWords : [Int:String] = [:]
    
    //MARK: - New school picker properties
    var editedSchoolNames : [String] = []
    @IBOutlet weak var schoolPickerHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lunch"
        loadedPDFURLs = UserDefaults.standard.object([Int:URL].self, with: "PDFLocations")!
        loadedWordURLs = UserDefaults.standard.object([Int:String].self, with: "WordLocations")!
        print(loadedPDFURLs)
        print(loadedWordURLs)
        view.backgroundColor = .csbcSuperLightGray
        loadingSymbol.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingSymbol.style = .large
        } else {
            loadingSymbol.style = .whiteLarge
            loadingSymbol.color = .gray
        }
        webView.navigationDelegate = self
        
        addShareBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadingSymbol.startAnimating()
        shouldIShowAllSchools(schoolPicker: schoolPicker, schoolPickerHeightConstraint: schoolPickerHeightConstraint)
        for i in 0..<schoolPicker.numberOfSegments {
            if schoolPicker.titleForSegment(at: i) == schoolSelected.ssString {
                schoolPicker.selectedSegmentIndex = i
            }
        }
        
        formatter.dateFormat = "EEEE, MMMM d"
        
        let dateString = formatter.string(from: date)
        dateLabel.text = "Today is \(dateString)"
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(reloadPDFView), userInfo: nil, repeats: false)
        reloadPDFView()
        
    }
    
    @IBAction func schoolPickerChanged(_ sender: Any) {
        schoolSelected.update(schoolPicker)
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
            pdfView.isHidden = true
            webView.isHidden = true
            loadingSymbol.startAnimating()
        }
        
        
    }
    
    @objc func canRotate() -> Void {}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        
    }
    
    func addShareBarButtonItem() {
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        
        self.navigationItem.rightBarButtonItem = shareButton
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

    
    @objc func shareButtonPressed() {
        if loadedPDFURLs[schoolSelected.ssInt] != nil && loadingSymbol.isHidden == true {
            let activityViewController = UIActivityViewController(activityItems: [PDFDocument(url: loadedPDFURLs[schoolSelected.ssInt]!)?.documentURL!], applicationActivities: nil)
            DispatchQueue.main.async {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        
    }
    
    func lunchMenuLoaded(at : Int) {
        reloadPDFView()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loadingSymbol.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingSymbol.stopAnimating()
    }
    
}
