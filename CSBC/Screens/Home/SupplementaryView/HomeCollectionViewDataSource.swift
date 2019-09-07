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
    
    private let buttonImages = ["Today","Portal","Contact","Calendar","News","Lunch","Athletics","Give","Connect","Dress Code","Docs","Options"]
    
    private let parent : HomeViewController!
    var lastSeguedWebView : WebViewController?
    
    init(forParentVC parent : HomeViewController) {
        self.parent = parent
    }
    
    func configureCollectionViewForCurrentScreenSize() {
        
        //Collection View and header setup
        parent.headerHeightConstraint.constant = ((UIScreen.main.bounds.height)/8) + 23//6.737
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
        
//        if let timeOfStuffDownloaded = UserDefaults.standard.string(forKey: "athleticsArrayTime"), let timeDate = timeOfStuffDownloaded.toDateWithTime() {
//            let timeFormatter = DateFormatter()
//            timeFormatter.dateFormat = "HH:mm:ss"
//            title = timeFormatter.string(from: timeDate)
//        }
        
        cell.displayContent(image: image!, title: title)
        return cell
    }
    
    
    
    //MARK: Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if parent != nil {
            let tag = indexPath.row + 1
            switch tag {
            case 1: //Today
                parent.performSegue(withIdentifier: "TodaySegue", sender: parent)
            case 2: //Portal
                lastSeguedWebView != nil ? parent.navigationController?.pushViewController(lastSeguedWebView!, animated: true) : parent.performSegue(withIdentifier: "WebSegue", sender: parent)
            case 3: //Contact
                parent.performSegue(withIdentifier: "ContactSegue", sender: parent)
            case 4: //Calendar
                parent.performSegue(withIdentifier: "CalendarSegue", sender: parent)
            case 5: //News
                parent.showNewsInSafariView()
            case 6: //Lunch
                parent.performSegue(withIdentifier: "LunchSegue", sender: parent)
            case 7: //Athletics
                parent.performSegue(withIdentifier: "AthleticsSegue", sender: parent)
            case 8: //Give
                if let url = URL(string: "https://app.mobilecause.com/form/N-9Y0w?vid=1hepr") {
                    UIApplication.shared.open(url)
                }
            case 9: //Connect
                parent.performSegue(withIdentifier: "SocialMediaSegue", sender: parent)
            case 10: //Dress Code
                parent.performSegue(withIdentifier: "UniformsSegue", sender: parent)
            case 11: //Docs
                parent.performSegue(withIdentifier: "DocumentsSegue", sender: parent)
            case 12: //Options
                parent.performSegue(withIdentifier: "SettingsSegue", sender: parent)
            default:
                break
            }
        }
        
    }
    
}
