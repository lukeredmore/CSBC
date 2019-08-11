//
//  LunchHTMLController.swift
//  CSBC
//
//  Created by Luke Redmore on 5/22/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import SwiftSoup
import SafariServices
import Alamofire
//import PDFKit

protocol LoadPDFDelegate: class {
    func tryToLoadPDFs()
}

/// Finds URLs of, download, and store all the lunch menus
class LunchHTMLController: NSObject, URLSessionDownloadDelegate {
    var lunchesReady : [Bool] = [false, false, false, false]
    var urls : [String] = ["","","",""]
    var i = 0
    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("Lunch Menu.pdf")
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    var loadedPDFURLs : [Int:URL] = [:]
    var loadedWordURLs : [Int:String] = [:]
    
    func downloadAndStoreLunchMenus() {
        lunchesReady = [false, false, false, false]
        let setonURL = URL(string: "https://csbcsaints.org/our-schools/seton-catholic-central/about-scc/about/")
        let setonTask = URLSession.shared.dataTask(with: setonURL!) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else { return }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                let data = data,
                let html = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.parseSetonLunchHTML(html: html)
                }
            }
        }
        let johnURL = URL(string: "http://www.bcsdfs.org/menu.cfm?mid=1372")
        let johnTask = URLSession.shared.dataTask(with: johnURL!) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else { return }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                let data = data,
                let html = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.parseJohnLunchHTML(html: html)
                }
            }
        }
        let saintsURL = URL(string: "https://csbcsaints.org/our-schools/all-saints-school/parent-resources/lunch-menu-meal-program/")
        let saintsTask = URLSession.shared.dataTask(with: saintsURL!) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else { return }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                let data = data,
                let html = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.parseSaintsLunchHTML(html: html)
                }
            }
        }
        let jamesURL = URL(string: "https://csbcsaints.org/our-schools/st-james-school/parent-resources/lunch-menu-meal-program/")
        let jamesTask = URLSession.shared.dataTask(with: jamesURL!) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else { return }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                let data = data,
                let html = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.parseJamesLunchHTML(html: html)
                }
            }
        }
        setonTask.resume()
        johnTask.resume()
        saintsTask.resume()
        jamesTask.resume()
    }
    func parseSetonLunchHTML(html : String) {
        do {
            let doc = try SwiftSoup.parse(html)
            let allAInfo = try doc.select("a").array()
            for i in 0..<allAInfo.count {
                let aValue = try allAInfo[i].html()
                if aValue.contains("Menu") {
                    //print(aValue)
                    let lunchJS = try allAInfo[i].attr("href")
                    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(in: lunchJS, options: [], range: NSRange(location: 0, length: lunchJS.utf16.count))
                    
                    for match in matches {
                        guard let range = Range(match.range, in: lunchJS) else { continue }
                        let url = lunchJS[range]
                        urls[0] = String(url)
                        lunchesReady[0] = true
                        tryToLoadPDFs()
                    }
                }
            }
        } catch {}
    }
    func parseJohnLunchHTML(html : String) {
        do {
            let doc = try SwiftSoup.parse(html)
            let allAInfo = try doc.select("a").array()
            for i in 0..<allAInfo.count {
                let aValue = try allAInfo[i].html()
                if aValue.contains("</b>") == false && aValue.contains("Lunch") && aValue.contains("Elementary") {
                    //print(aValue)
                    let lunchJS = try allAInfo[i].attr("href")
                    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(in: lunchJS, options: [], range: NSRange(location: 0, length: lunchJS.utf16.count))
                    
                    for match in matches {
                        guard let range = Range(match.range, in: lunchJS) else { continue }
                        let url = lunchJS[range]
                        urls[1] = String(url)
                        lunchesReady[1] = true
                        tryToLoadPDFs()
                    }
                }
            }
        } catch {}
    }
    func parseSaintsLunchHTML(html : String) {
        do {
            let doc = try SwiftSoup.parse(html)
            let allAInfo = try doc.select("div").array()
            for i in 0..<allAInfo.count {
                let divClass = try allAInfo[i].attr("class")
                if divClass == "et_pb_blurb_description" {
                    let lunchJS = try allAInfo[i].html()
                    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(in: lunchJS, options: [], range: NSRange(location: 0, length: lunchJS.utf16.count))
                    
                    for match in matches {
                        guard let range = Range(match.range, in: lunchJS) else { continue }
                        let url = lunchJS[range]
                        //print(url)
                        urls[2] = String(url)
                        lunchesReady[2] = true
                        tryToLoadPDFs()
                    }
                }
            }
        } catch {}
    }
    func parseJamesLunchHTML(html : String) {
        do {
            let doc = try SwiftSoup.parse(html)
            let allAInfo = try doc.select("div").array()
            for i in 0..<allAInfo.count {
                let divClass = try allAInfo[i].attr("class")
                if divClass == "et_pb_blurb_description" {
                    let lunchJS = try allAInfo[i].html()
                    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(in: lunchJS, options: [], range: NSRange(location: 0, length: lunchJS.utf16.count))
                    
                    for match in matches {
                        guard let range = Range(match.range, in: lunchJS) else { continue }
                        let url = lunchJS[range]
                        urls[3] = String(url)
                        lunchesReady[3] = true
                        tryToLoadPDFs()
                    }
                }
            }
        } catch {}
    }
    
    func tryToLoadPDFs() {
        if lunchesReady == [true, true, true, true] {
            print("Starting document downloads")
            i = 0
            
            downloadPDFs()
        }
    }
    func downloadPDFs() {
        let urlSplit = urls[i].components(separatedBy: ".")
        if urlSplit.last == "pdf" {
            guard let url = URL(string: urls[i]) else { return }
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            let downloadTask = urlSession.downloadTask(with: url)
            downloadTask.resume()
            print(urls[i], " downloading")
//            Alamofire.download(URL(string: urls[i])!, to: destination).response { response in
//                if response.error == nil, let _ = response.destinationURL?.path {
//                    self.pdfDownloadCompletionHandler(response: response.destinationURL!)
//                }
//            }
        } else {
            msWordDownloadCompletionhandler(url: urls[i])
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            print("PDF \(i + 1) downloaded")
            loadedPDFURLs[i] = destinationURL
            i += 1
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
            i += 1
        }
        if i < 4 {
            downloadPDFs()
        } else {
            UserDefaults.standard.set(object: loadedWordURLs, forKey: "WordLocations")
            UserDefaults.standard.set(object: loadedPDFURLs, forKey: "PDFLocations")
        }
    }
    func msWordDownloadCompletionhandler(url : String) {
        loadedWordURLs[i] = url
        i += 1
        if i < 4 {
            downloadPDFs()
        } else {
            UserDefaults.standard.set(object: loadedWordURLs, forKey: "WordLocations")
            UserDefaults.standard.set(object: loadedPDFURLs, forKey: "PDFLocations")
            
        }
    }
}
