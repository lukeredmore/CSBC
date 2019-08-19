//
//  EventsRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 8/3/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import WebKit

protocol JSParsingDelegate : class {
    func loadCalendar(forNumberOfMonthsInFuture number : Int, parent : EventsRetriever)
}

class EventsRetriever : NSObject, WKNavigationDelegate {
    private let preferences = UserDefaults.standard
    weak var delegate : JSParsingDelegate!
    let completion : ([EventsModel?]) -> Void
    let dataParser = EventsDataParser()
    
    var monthCount = 0
    
    var monthCheckingString : String {
        let dateComponents = DateComponents(month: monthCount)
        let date = Calendar.current.date(byAdding: dateComponents, to: Date())
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        return monthFormatter.string(from: date!).lowercased()
    }
    
    init(delegate: JSParsingDelegate, completion: @escaping ([EventsModel?]) -> Void) {
        self.delegate = delegate
        self.completion = completion
        super.init()
    }
    
    func retrieveEventsArray(forceReturn : Bool = false, forceRefresh: Bool = false) {
        if forceRefresh {
            print("Events Data is being force refreshed")
            getEventsDataFromOnline()
        } else if forceReturn {
            print("Events Data is being force returned")
            if let json = preferences.value(forKey:"eventsArray") as? Data {
                print("Force return found an old JSON value")
                let optionalModel = try? PropertyListDecoder().decode([EventsModel?].self, from: json)
                return completion(optionalModel ?? [EventsModel]())
            } else {
                print("Force return returned an empty array")
                return completion([EventsModel]())
            }
        } else {
            print("Attempting to retrieve stored Events data.")
            if let eventsArrayTimeString = preferences.string(forKey: "eventsArrayTime"),
                let json = preferences.value(forKey:"eventsArray") as? Data { //If both events values are defined
                let eventsArrayTime = eventsArrayTimeString.toDateWithTime()! + 3600 //Time one hour in future
                if eventsArrayTime > Date() {
                    print("Up-to-date Events data found, no need to look online.")
                    return completion(try! PropertyListDecoder().decode([EventsModel?].self, from: json))
                } else {
                    print("Events data found, but is old. Will refresh online.")
                    getEventsDataFromOnline()
                }
            } else {
                print("No Events data found in UserDefaults. Looking online.")
                getEventsDataFromOnline()
            }
        }
    }
    private func getEventsDataFromOnline() {
        print("We are asking for Events data")
        delegate.loadCalendar(forNumberOfMonthsInFuture: monthCount, parent: self)
    }
    
    
    func scrapeWKWebViewUntilCurrentMonthIsFound(forWebView webView : WKWebView) {
        //            "document.querySelector('#evcal_list').outerHTML.toString()"
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") {
            response, error in
            if let responseString = response as? String {
                if !responseString.contains(self.monthCheckingString) {
                    print("\(self.monthCheckingString) has not let been loaded by WKWebView. Checking again.")
                    self.scrapeWKWebViewUntilCurrentMonthIsFound(forWebView: webView)
                } else {
                    self.htmlStringWasScrapedFromCalendar(htmlString: response as! String)
                    webView.removeFromSuperview()
                }
            }
        }
    }
    func htmlStringWasScrapedFromCalendar(htmlString: String) {
        print("Data for month of \(monthCheckingString) has been scraped. Now parsing.")
        dataParser.parseHTMLForEvents(fromString: htmlString)
        self.retrieveEventsArray()
        monthCount += 1
        if monthCount < 2 {
            print("Now scraping for month of \(monthCheckingString)")
            delegate.loadCalendar(forNumberOfMonthsInFuture: monthCount, parent: self)
        } else { print("All data has been collected") }
    }
    
    
    //MARK: WKWebView Delegate Methods
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("WKWebView began to load")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("WKWebView waited to parse for 1 second to save power, now scraping")
            self.scrapeWKWebViewUntilCurrentMonthIsFound(forWebView: webView)
        }
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WKWebView didFailProvisionalNavigation: Force returning")
        retrieveEventsArray(forceReturn: true, forceRefresh: false)
        webView.removeFromSuperview()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WKWebView didFail: Force returning")
        retrieveEventsArray(forceReturn: true, forceRefresh: false)
        webView.removeFromSuperview()
    }
}


//MARK: Protocol implementations
extension CalendarViewController: JSParsingDelegate {
    func loadCalendar(forNumberOfMonthsInFuture number : Int, parent : EventsRetriever) {
        var jsSource = ""
        
        for _ in 0..<number {
            jsSource += "document.getElementById('evcal_next').click();"
        }
        
        let script = WKUserScript(source: jsSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let contentController = WKUserContentController()
        contentController.addUserScript(script)
        
        let myConfiguration = WKWebViewConfiguration()
        myConfiguration.userContentController = contentController
        myConfiguration.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: myConfiguration)
        //        webView.frame = CGRect(x: 20, y: -10, width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 440)
        webView.navigationDelegate = parent
        
        view.addSubview(webView)
        if let url = URL(string: "https://csbcsaints.org/calendar") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
extension PageViewController {
    func loadCalendar(forNumberOfMonthsInFuture number : Int, parent : EventsRetriever) {
        var jsSource = ""
        
        for _ in 0..<number {
            jsSource += "document.getElementById('evcal_next').click();"
        }
        
        let script = WKUserScript(source: jsSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let contentController = WKUserContentController()
        contentController.addUserScript(script)
        
        let myConfiguration = WKWebViewConfiguration()
        myConfiguration.userContentController = contentController
        myConfiguration.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: myConfiguration)
        webView.isHidden = true
        //        webView.frame = CGRect(x: 20, y: -10, width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 440)
        webView.navigationDelegate = parent
        
        view.addSubview(webView)
        if let url = URL(string: "https://csbcsaints.org/calendar") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
