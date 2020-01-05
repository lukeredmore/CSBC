//
//  PushNotificationSender.swift
//  CSBC
//
//  Created by Luke Redmore on 5/26/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation

/// Takes a given notification and publishes it with preconfigured settings and reports to a completion
class PushNotificationSender {
    
    static func send(withMessage message : String, toSchool school : Schools, completion: ((String?) -> Void)? = nil) {
        let url = "https://us-east4-csbcprod.cloudfunctions.net/sendMessageFromAdmin"
        let params : [String : Any] = [
            "message": message,
            "schoolInt": school.rawValue
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
