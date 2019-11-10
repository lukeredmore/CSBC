//
//  HomeCollectionController.swift
//  CSBC
//
//  Created by Luke Redmore on 6/30/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

///Home screen UICollectionView data source and delegate
class HomeCollectionController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    private let buttonImages = ["Today","Portal","Contact","Calendar","News","Lunch","Athletics","Give","Connect","Dress Code","Docs","Options"]
    private let segueDelegate : SegueDelegate!
    
    init(segueDelegate : SegueDelegate) {
        self.segueDelegate = segueDelegate
        super.init()
    }
    
    //MARK: DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! CSBCCollectionViewCell
        let image = UIImage(named: buttonImages[indexPath.row])
        let title = buttonImages[indexPath.row]
        
        cell.displayContent(image: image, title: title)
        return cell
    }
    
    
    
    //MARK: Delegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let tag = indexPath.row + 1
        switch tag {
        case 1: //Today
            segueDelegate.performSegue(withIdentifier: "TodaySegue", sender: nil)
        case 2: //Portal
            if let existingWebView = segueDelegate.lastSeguedWebView, let parentNav = segueDelegate.navigationController {
                parentNav.pushViewController(existingWebView, animated: true)
            } else { segueDelegate.performSegue(withIdentifier: "WebSegue", sender: nil) }
        case 3: //Contact
            segueDelegate.performSegue(withIdentifier: "ContactSegue", sender: nil)
        case 4: //Calendar
            let vc = CalendarTableViewController(configuration: CalendarTableViewController.configuration)
            segueDelegate.navigationController?.pushViewController(vc, animated: true)
        case 5: //News
            segueDelegate.performSegue(withIdentifier: "NewsSegue", sender: nil)
        case 6: //Lunch
            segueDelegate.performSegue(withIdentifier: "LunchSegue", sender: nil)
        case 7: //Athletics
            let vc = AthleticsTableViewController(configuration: AthleticsTableViewController.configuration)
            segueDelegate.navigationController?.pushViewController(vc, animated: true)
        case 8: //Give
            guard let url = URL(string: "https://app.mobilecause.com/form/N-9Y0w?vid=1hepr") else { break }
            UIApplication.shared.open(url)
        case 9: //Connect
            segueDelegate.performSegue(withIdentifier: "SocialMediaSegue", sender: nil)
        case 10: //Dress Code
            segueDelegate.performSegue(withIdentifier: "UniformsSegue", sender: nil)
        case 11: //Docs
            segueDelegate.performSegue(withIdentifier: "DocumentsSegue", sender: nil)
        case 12: //Options
            segueDelegate.performSegue(withIdentifier: "SettingsSegue", sender: nil)
        default:
            break
        }
    }
    
}
