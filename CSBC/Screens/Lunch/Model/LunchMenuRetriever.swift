//
//  LunchMenuRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 5/22/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import Firebase


/// Finds URLs of, download, and store all the lunch menus
class LunchMenuRetriever {
    
    private static func tryToLoadPDFs(fromURLs urls : [Schools:URL]) {
        for (school, url) in urls {
            if url.absoluteString.components(separatedBy: ".").last == "pdf" {
                let downloadTask = URLSession(configuration: .default, delegate: LunchSessionDelegate(forSchool: school), delegateQueue: OperationQueue()).downloadTask(with: url)
                downloadTask.resume()
            } else {
                var loadedWordURLs = UserDefaults.standard.object([Int:URL].self, with: "LunchURLs") ?? [:]
                loadedWordURLs[school.rawValue] = url
                UserDefaults.standard.set(object: loadedWordURLs, forKey: "LunchURLs")
            }
        }
        
    }
    static func downloadLunchMenus() {
            Database.database().reference().child("Lunch/Links").observeSingleEvent(of: .value) { snapshot in
                guard let lunchDict = snapshot.value as? [String:String] else { return }
                print("Lunch links found:")
                print(lunchDict)
                let urlDict : [Schools:URL] = [
                    .seton : URL(string: lunchDict["seton"]!)!,
                    .saints : URL(string: lunchDict["saints"]!)!,
                    .john : URL(string: lunchDict["johnjames"]!)!,
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
