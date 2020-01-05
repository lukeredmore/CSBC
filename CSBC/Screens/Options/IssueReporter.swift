//
//  IssueReporter.swift
//  CSBC
//
//  Created by Luke Redmore on 1/1/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

///Reports an issue to firebase cloud functions
class IssueReporter {
    
    static func report(_ message : String, completion: ((String?) -> Void)? = nil) {
        let url = "https://us-east4-csbcprod.cloudfunctions.net/sendReportEmail"
        let params : [String : String] = [
            "body": "<i>App version: \(Bundle.versionString)</i>\n<hr>\n\(message)",
            "sender": "CSBC App Issue",
            "subject": "New App Issue: \(Date().dateString())"
        ]
        guard let request = URLRequest.createWithParameters(fromURLString: url, parameters: params) else {
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
}
