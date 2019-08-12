//
//  HomeCollectionViewDelegate.swift
//  CSBC
//
//  Created by Luke Redmore on 6/30/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UIKit

/// Home screen UICollectionView data source and delegate
class HomeCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let buttonImages : [String] = ["Today","Portal","Contact","Calendar","News","Lunch","Athletics","Give","Connect","Dress Code","Docs","Options"]
    private var columnLayout = ColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: (UIScreen.main.bounds.width)/15.88,
        minimumLineSpacing: (UIScreen.main.bounds.height-133)/15.88,
        sectionInset: UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)
    )
    private var parent : HomeViewController? = nil
    
    func configureCollectionViewForScreenSize(_ parent: HomeViewController) {
        self.parent = parent
        if UIDevice.current.orientation.isLandscape {
            columnLayout.cellsPerRow = 4
        } else {
            columnLayout.cellsPerRow = 3
        }
        columnLayout.minimumInteritemSpacing = (UIScreen.main.bounds.width)/9
        columnLayout.minimumLineSpacing = (UIScreen.main.bounds.height-133)/12
        if UIScreen.main.bounds.width == 1366 {
            columnLayout.minimumLineSpacing = (UIScreen.main.bounds.height-133)/9
            columnLayout.sectionInset = UIEdgeInsets(top: 35.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if UIScreen.main.bounds.width == 1112 {
            columnLayout.sectionInset = UIEdgeInsets(top: 60.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if UIScreen.main.bounds.height == 1366 {
            columnLayout.sectionInset = UIEdgeInsets(top: 20.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if parent.view.traitCollection.horizontalSizeClass == .regular && UIDevice.current.orientation.isLandscape {
            columnLayout.sectionInset = UIEdgeInsets(top: 35.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if parent.view.traitCollection.horizontalSizeClass == .regular {
            columnLayout.sectionInset = UIEdgeInsets(top: 30.0, left: 60.0, bottom: 30.0, right: 60.0)
        } else {
            print("Application is running on an iPhone")
            columnLayout.minimumInteritemSpacing = 0//(UIScreen.main.bounds.width)/16
            columnLayout.minimumLineSpacing = (UIScreen.main.bounds.height-133)/15.88
            columnLayout.sectionInset = UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)
        }
        //Collection View and header setup
        parent.headerHeightConstraint.constant = ((UIScreen.main.bounds.height)/8) + 23//6.737
        parent.collectionView.collectionViewLayout = columnLayout
        parent.collectionView.contentInsetAdjustmentBehavior = .always
        parent.collectionView.reloadData()
    }
    
    //MARK: DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        let image = UIImage(named: buttonImages[indexPath.row])
        let title = buttonImages[indexPath.row]
        cell.displayContent(image: image!, title: title)
        return cell
    }
    
    //MARK: Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if parent != nil {
            let tag : Int = indexPath.row + 1
            switch tag {
            case 1: //Today
                parent!.performSegue(withIdentifier: "TodaySegue", sender: parent!)
            case 2: //Portal
                parent!.performSegue(withIdentifier: "WebSegue", sender: parent!)
            case 3: //Contact
                parent!.performSegue(withIdentifier: "ContactSegue", sender: parent!)
            case 4: //Calendar
                parent!.performSegue(withIdentifier: "CalendarSegue", sender: parent!)
            case 5: //News
                parent!.showNewsInSafariView()
            case 6: //Lunch
                parent!.performSegue(withIdentifier: "LunchSegue", sender: parent!)
            case 7: //Athletics
                parent!.performSegue(withIdentifier: "AthleticsSegue", sender: parent!)
            case 8: //Give
                if let url = URL(string: "https://app.mobilecause.com/form/N-9Y0w?vid=1hepr") {
                    UIApplication.shared.open(url)
                }
            case 9: //Connect
                parent!.performSegue(withIdentifier: "SocialMediaSegue", sender: parent!)
            case 10: //Dress Code
                parent!.performSegue(withIdentifier: "UniformsSegue", sender: parent!)
            case 11: //Docs
                parent!.performSegue(withIdentifier: "DocumentsSegue", sender: parent!)
            case 12: //Options
                parent!.performSegue(withIdentifier: "SettingsSegue", sender: parent!)
            default:
                break
            }
        }
        
    }
    
}
