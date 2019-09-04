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
    private static let lunchURLLocations = ["https://csbcsaints.org/our-schools/seton-catholic-central/about-scc/about/", "http://www.rockoncafe.org/Menus_B.aspx", "https://csbcsaints.org/our-schools/all-saints-school/parent-resources/lunch-menu-meal-program/", "https://csbcsaints.org/our-schools/st-james-school/parent-resources/lunch-menu-meal-program/"]
    private static let htmlParsers : [(Document) -> String?] = [parseSetonLunchHTML, parseJohnLunchHTML, parseJamesLunchHTML, parseSaintsLunchHTML]
    
    private static var lunchesReady = [false, false, false, false]
    private static var urls : [String?] = [nil, nil, nil, nil]
    
    
    static func downloadAndStoreLunchMenus() {
        for i in 0..<4 {
            let task = URLSession.shared.dataTask(with: URL(string: lunchURLLocations[i])!) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode),
                    let mimeType = httpResponse.mimeType, mimeType == "text/html",
                    let data = data,
                    let htmlString = String(data: data, encoding: .utf8),
                    let html = try? SwiftSoup.parse(htmlString),
                    let url = self.htmlParsers[i](html) {
                    self.urls[i] = url
                }
                self.lunchesReady[i] = true
                self.tryToLoadPDFs()
            }
            task.resume()
        }
    }
    
    
    private static func parseSetonLunchHTML(doc : Document) -> String? {
        do {
            let menuItems = try doc.select(".mega-menu-link").array()
            for menuItem in menuItems {
                if try menuItem.text().lowercased().contains("menu") {
                    return try menuItem.attr("href")
                }
            }
        } catch {print("error parsing seton")}; return nil
    }
    private static func parseJohnLunchHTML(doc : Document) -> String? {
        do {
            let lunchListGroups = try doc.select(".linksList").array()
            for lunchList in lunchListGroups {
                let links = try lunchList.select("li a").array()
                for link in links {
                    if try link.text().lowercased().contains("john") {
                        return try link.attr("href").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    }
                }
            }
        } catch {print("error parsing john")}; return nil
    }
    private static func parseSaintsLunchHTML(doc : Document) -> String? {
        do {
            let allAInfo = try doc.select(".et_section_regular a").array()
            for element in allAInfo {
                if try (element.text().lowercased().contains("lunch") || element.text().lowercased().contains("menu")) && !element.attr("href").contains("18") {
                    return try element.attr("href")
                }
            }
        } catch {print("error parsing saints")}; return nil
    }
    private static func parseJamesLunchHTML(doc : Document) -> String? {
        do {
            let allAInfo = try doc.select(".et_section_regular a").array()
            for element in allAInfo {
                if try (element.text().lowercased().contains("lunch") || element.text().lowercased().contains("menu")) && !element.attr("href").contains("18") {
                    return try element.attr("href")
                }
            }
        } catch {print("error parsing james")}; return nil
    }
    
    private static func tryToLoadPDFs() {
        var loadedWordURLs : [Int:String] = [:]
        if lunchesReady == [true, true, true, true] {
            print("Starting document downloads from urls: \(urls)")
            for case let urlString? in urls {
                guard let url = URL(string: urlString) else { continue }
                let fileExtensionOnURL = urlString.components(separatedBy: ".").last
                if fileExtensionOnURL == "pdf" {
                    let urlSession = URLSession(configuration: .default, delegate: LunchSessionDelegate(withURLs: urls), delegateQueue: OperationQueue())
                    let downloadTask = urlSession.downloadTask(with: url)
                    downloadTask.resume()
                } else {
                    guard let originalIndex = urls.firstIndex(of: urlString) else { continue }
                    loadedWordURLs[originalIndex] = urlString
                    UserDefaults.standard.set(object: loadedWordURLs, forKey: "WordLocations")
                }
            }
            
        }
    }
}

class LunchSessionDelegate : NSObject, URLSessionDownloadDelegate {
    private let urls : [String?]!
    private var loadedPDFURLs : [Int:URL] {
        get { UserDefaults.standard.object([Int:URL].self, with: "PDFLocations") ?? [:] }
        set { UserDefaults.standard.set(object: newValue, forKey: "PDFLocations") }
    }
    
    internal init(withURLs urls: [String?]) {
        self.urls = urls
    }
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        print("downloadLocation:", location)
        guard let url = downloadTask.originalRequest?.url,
            let originalIndex = urls.firstIndex(of: url.absoluteString) else { return }
        
        let destinationURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            print("PDF \(originalIndex + 1) downloaded")
            loadedPDFURLs[originalIndex] = destinationURL
        } catch let error {
            print("Copy Error on PDF \(originalIndex + 1): \(error.localizedDescription)")
        }
    }
}
