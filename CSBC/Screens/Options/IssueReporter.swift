//
//  IssueReporter.swift
//  CSBC
//
//  Created by Luke Redmore on 1/1/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

class IssueReporter {
    
    static func sendMessage(_ message : String, completion: ((String?) -> Void)? = nil) {
        
        let url = "https://us-east4-csbcprod.cloudfunctions.net/sendReportEmail"
        let params : [String : String] = [
            "body": "<i>App version: \(Bundle.versionString)</i>\n<hr>\n\(message)",
            "sender": "CSBC App Issue",
            "subject": "New App Issue: \(Date().dateString())"
        ]
        guard let request = createURLRequestForPost(urlString: url, data: params) else {
            print("Invalid URLRequest")
            completion?("Invalid URLRequest")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion?(error?.localizedDescription)
            }
        }
        task.resume()
    }
    
    private static func createURLRequestForPost(urlString: String, data: [String : String]) -> URLRequest? {
        var urlToSend = "\(urlString)?"
        for (k, v) in data {
            urlToSend += "\(k)=\(v)&"
        }
        urlToSend.removeLast()
        urlToSend = urlToSend.replacingOccurrences(of: "\n", with: "<br>")
        urlToSend = urlToSend.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        guard let url = URL(string: urlToSend) else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
