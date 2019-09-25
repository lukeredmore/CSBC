//
//  LunchMenuRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 5/22/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import SwiftSoup
import SafariServices


/// Finds URLs of, download, and store all the lunch menus
class LunchMenuRetriever {
    private static let lunchMenuInformation : [Schools : (String, (Document) -> String?)] = [
        .seton : ("https://csbcsaints.org/our-schools/seton-catholic-central/about-scc/about/", parseSetonLunchHTML),
        .john : ("http://www.rockoncafe.org/Menus_B.aspx", parseJohnLunchHTML),
        .saints : ("https://csbcsaints.org/our-schools/all-saints-school/parent-resources/lunch-menu-meal-program/", parseJamesLunchHTML),
        .james : ("https://csbcsaints.org/our-schools/st-james-school/parent-resources/lunch-menu-meal-program/", parseSaintsLunchHTML)
    
    ]
    private static var lunchesReady : [Schools:Bool] = [.seton : false, .john : false, .saints : false, .james : false]
    private static var urlDict = [Schools:URL]()
    
    
    static func downloadAndStoreLunchMenus() {
        
        for (school, (urlString, htmlParser)) in lunchMenuInformation {
            let task = URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                    let mimeType = httpResponse.mimeType, mimeType == "text/html",
                    let data = data, let htmlString = String(data: data, encoding: .utf8), let html = try? SwiftSoup.parse(htmlString),
                    let lunchURLString = htmlParser(html),
                    let lunchURL = URL(string: lunchURLString) {
                    
                    self.urlDict[school] = lunchURL
                }
                self.lunchesReady[school] = true
                self.tryToLoadPDFs(fromURLs: urlDict)
            }
            task.resume()
        }
    }
    
    
    private static func parseSetonLunchHTML(doc : Document) -> String? {
        do {
            let menuItems = try doc.select(".mega-menu-link").array()
            for menuItem in menuItems where try menuItem.text().lowercased().contains("menu") {
                return try menuItem.attr("href")
            }
        } catch { print("error parsing seton") }; return nil
    }
    private static func parseJohnLunchHTML(doc : Document) -> String? {
        do {
            let lunchListGroups = try doc.select(".linksList").array()
            for lunchList in lunchListGroups {
                let links = try lunchList.select("li a").array()
                for link in links where try link.text().lowercased().contains("john") {
                    return try link.attr("href").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                }
            }
        } catch { print("error parsing john") }; return nil
    }
    private static func parseSaintsLunchHTML(doc : Document) -> String? {
        do {
            let allAInfo = try doc.select(".et_section_regular a").array()
            for element in allAInfo where try (element.text().lowercased().contains("lunch") || element.text().lowercased().contains("menu")) && !element.attr("href").contains("18") {
                return try element.attr("href")
            }
        } catch { print("error parsing saints") }; return nil
    }
    private static func parseJamesLunchHTML(doc : Document) -> String? {
        do {
            let allAInfo = try doc.select(".et_section_regular a").array()
            for element in allAInfo where try (element.text().lowercased().contains("lunch") || element.text().lowercased().contains("menu")) && !element.attr("href").contains("18") {
                return try element.attr("href")
            }
        } catch { print("error parsing james") }; return nil
    }
    
    private static func tryToLoadPDFs(fromURLs urls : [Schools:URL]) {
        guard Array(lunchesReady.values) == [true, true, true, true] else { return }
        print("Starting document downloads from urls:\n\(urls)")
        for (school, url) in urls {
            if url.absoluteString.components(separatedBy: ".").last == "pdf" {
                let downloadTask = URLSession(configuration: .default, delegate: LunchSessionDelegate(forSchool: school), delegateQueue: OperationQueue()).downloadTask(with: url)
                downloadTask.resume()
            } else {
                var loadedWordURLs = UserDefaults.standard.object([Int:String].self, with: "WordLocations") ?? [:]
                loadedWordURLs[school.rawValue] = url.absoluteString
                UserDefaults.standard.set(object: loadedWordURLs, forKey: "WordLocations")
            }
        }
        
    }
}


class LunchSessionDelegate : NSObject, URLSessionDownloadDelegate {
    private let school : Schools!
    private var loadedPDFURLs : [Int:URL] {
        get { UserDefaults.standard.object([Int:URL].self, with: "PDFLocations") ?? [:] }
        set { UserDefaults.standard.set(object: newValue, forKey: "PDFLocations") }
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
            print("\(school.ssString) Lunch Menu downloaded")// from url: \(url.absoluteString)")
            loadedPDFURLs[school.rawValue] = destinationURL
        } catch let error {
            print("Copy Error on PDF \(school.rawValue + 1): \(error.localizedDescription)")
        }
    }
}
