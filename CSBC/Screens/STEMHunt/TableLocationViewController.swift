//
//  TableLocationViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 1/11/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class TableLocationViewController: CSBCSearchViewController<STEMTableModel, STEMTableCell> {
    private lazy var stemRetriever = STEMRetriever(completion: receiveSet)
    
    init() {
        UserDefaults.standard.set(UIColor.stemBaseBlue, forKey: "customNavBarColor")
        UserDefaults.standard.set(UIColor.stemLightBlue, forKey: "customSearchFieldColor")
        UserDefaults.standard.set(UIColor.orange, forKey: "customBarColor")
        let configuration = CSBCSearchConfiguration(
            pageTitle: "STEM Night",
            emptyDataMessage: "No tables found",
            emptySearchMessage: "No tables found",
            xibIdentifier: "STEMTableCell",
            refreshConfiguration: .never,
            allowSelection: .selection,
            searchPlaceholder: "Search",
            backgroundButtonText: "Reset"
        )
        super.init(configuration: configuration)
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([
        NSAttributedString.Key.font: UIFont(name: "DINCondensed-Bold", size: 25)!,
        NSAttributedString.Key.foregroundColor: UIColor.orange
        ], for: .normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([
        NSAttributedString.Key.font: UIFont(name: "DINCondensed-Bold", size: 25)!,
        NSAttributedString.Key.foregroundColor: UIColor.orange
        ], for: .highlighted)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc func close() {
        dismiss(animated: true)
        UserDefaults.standard.set(nil, forKey: "customNavBarColor")
        UserDefaults.standard.set(nil, forKey: "customSearchFieldColor")
        UserDefaults.standard.set(nil, forKey: "customBarColor")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchLoadingSymbol.startAnimating()
        stemRetriever.retrieveSTEMArray()
    }
    
    override func cellSelected(withModel model : STEMTableModel, forCell cell : STEMTableCell) {
        let vc = STEMInfoViewController(for: model) {
            self.stemRetriever.answer(for: model)
        }
        present(vc, animated: true)
    }
    
    override func backgroundButtonPressed() {
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let reset = UIAlertAction(title: "Reset", style: .destructive) { action in
            UserDefaults.standard.set(nil, forKey: "stemAnswered")
            self.stemRetriever.retrieveSTEMArray()
        }
        let controller = UIAlertController(title: "Are you sure you want to reset your scavenger hunt?", message: "All progress will be lost", preferredStyle: .actionSheet)
        controller.addAction(cancel)
        controller.addAction(reset)
        present(controller, animated: true)
    }
    
    func receiveSet(_ modelList : Set<STEMTableModel>, _ _ : Bool) {
        loadTable(withData: modelList, isDummyData: false)
        if userDidFinishScavengerHunt(listOfVendors: modelList) {
            print("User has won")
        } else {
            print("user hasn't won")
        }
    }
    
    private func userDidFinishScavengerHunt(listOfVendors : Set<STEMTableModel>) -> Bool {
        for each in listOfVendors {
            if !each.answered { return false }
        }
        return true
    }
}
