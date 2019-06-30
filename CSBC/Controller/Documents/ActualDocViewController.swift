//
//  ActualDocViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 2/10/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import PDFKit


class ActualDocViewController: UIViewController {

    //var schoolSelected = 0
    @IBOutlet weak var pdfView: PDFView!
    
    var clickedDocument : PDFDocument?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .csbcSuperLightGray
        addShareBarButtonItem()
        self.navigationItem.title = ""
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        pdfView.document = clickedDocument!
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        let defaultScale = pdfView.scaleFactorForSizeToFit - 0.07
        pdfView.scaleFactor = defaultScale
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = defaultScale
        view.addSubview(pdfView)
        
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
    
    @objc func shareButtonPressed() {
        if clickedDocument != nil {
            let activityViewController = UIActivityViewController(activityItems: [self.clickedDocument!.documentURL!], applicationActivities: nil)
            DispatchQueue.main.async {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        
    }

}
