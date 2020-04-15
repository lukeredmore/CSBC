//
//  LunchMenuRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 5/22/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON


/// Finds URLs of, download, and store all the lunch menus
class LunchMenuRetriever {
    
    private static func tryToLoadPDFs(fromURLs urls : [Schools:URL?]) {
        for (school, url) in urls {
            if url?.absoluteString.components(separatedBy: ".").last == "pdf" {
                let downloadTask = URLSession(configuration: .default, delegate: LunchSessionDelegate(forSchool: school), delegateQueue: OperationQueue()).downloadTask(with: url!)
                downloadTask.resume()
            } else {
                var loadedWordURLs = UserDefaults.standard.object([Int:URL].self, with: "LunchURLs") ?? [:]
                loadedWordURLs[school.rawValue] = url
                UserDefaults.standard.set(object: loadedWordURLs, forKey: "LunchURLs")
            }
        }
        
    }
    static func downloadLunchMenus() {
        Database.database().reference(withPath: "Schools").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else { return }
            let schoolsJson = JSON(value)
            let seton = schoolsJson["seton"]["info"]["lunchURL"].string ?? "nil"
            let saints = schoolsJson["saints"]["info"]["lunchURL"].string ?? "nil"
            let john = schoolsJson["john"]["info"]["lunchURL"].string ?? "nil"
            let james = schoolsJson["james"]["info"]["lunchURL"].string ?? "nil"
            print("Lunch links found:")
            print(seton, saints, john, james)
            
            let urlDict : [Schools:URL?] = [
                .seton : URL(string: seton),
                .saints : URL(string: saints),
                .john : URL(string: john),
                .james : URL(string: james)
            ]
            self.tryToLoadPDFs(fromURLs: urlDict)
        }
    }
}


class LunchSessionDelegate : NSObject, URLSessionDownloadDelegate {
    private let school : Schools!
    private var loadedPDFURLs : [Int:URL] {
        get { UserDefaults.standard.object([Int:URL].self, with: "LunchURLs") ?? [:] }
        set { UserDefaults.standard.set(object: newValue, forKey: "LunchURLs") }
    }
    
    internal init(forSchool school : Schools) {
        self.school = school
    }
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        print("downloadLocation:", location)
        guard let url = downloadTask.originalRequest?.url else { return }
        
        let destinationURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            print("\(school.shortName) Lunch Menu downloaded")
            loadedPDFURLs[school.rawValue] = destinationURL
        } catch let error {
            print("Copy Error on PDF \(school.rawValue + 1): \(error.localizedDescription)")
        }
    }
    
    
}
