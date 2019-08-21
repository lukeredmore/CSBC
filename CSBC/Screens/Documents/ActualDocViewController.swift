//
//  ActualDocViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/10/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import PDFKit

///Displays PDF supplied by parent
class ActualDocViewController: UIViewController {
    @IBOutlet weak private var pdfView: PDFView!
    var documentToDisplay : PDFDocument?
    
    
    //MARK: View Control
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .csbcAccentGray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        self.navigationItem.title = ""
    }
    override func viewWillAppear(_ animated: Bool) {
        configurePDFToDisplay()
    }
    
    
    //MARK: Rotational Methods
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
    
    
    //MARK: PDF Methods
    @objc private func shareButtonPressed() {
        if documentToDisplay != nil {
            let activityViewController = UIActivityViewController(activityItems: [self.documentToDisplay?.documentURL! as Any], applicationActivities: nil)
            DispatchQueue.main.async {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    private func configurePDFToDisplay() {
        if let doc = documentToDisplay {
            pdfView.document = doc
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
            let defaultScale = pdfView.scaleFactorForSizeToFit - 0.07
            pdfView.scaleFactor = defaultScale
            pdfView.maxScaleFactor = 4.0
            pdfView.minScaleFactor = defaultScale
            view.addSubview(pdfView)
        }
    }
}
