//
//  CustomNetworking.swift
//  CSBC
//
//  Created by Luke Redmore on 4/8/20.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

/// Sends a POST request authenticated through FirebaseAuth
struct CustomNetworkingResponse {
    let status: Int
    let message: String
}

class CustomNetworking {
    static func sendAuthenticatedPostRequest(url urlString: String, body: [String:String], completion: ((CustomNetworkingResponse) -> Void)? = nil) {
        Auth.auth().currentUser?.getIDToken { (token, error) in
            if let error = error {
                completion?(CustomNetworkingResponse(status: 500, message: error.localizedDescription))
            } else if let token = token {
                let session = URLSession.shared
                guard let url = URL(string: urlString) else {
                    completion?(CustomNetworkingResponse(status: 500, message: "Invalid URL"))
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                let jsonData = try! JSONSerialization.data(withJSONObject: body, options: [])
                let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion?(CustomNetworkingResponse(status: 500, message: "An unknown error occurred"))
                        
                    } else if let response = response, let httpResponse = response as? HTTPURLResponse, let data = data, let json = try? JSON(data: data) {
                        completion?(CustomNetworkingResponse(status: httpResponse.statusCode, message: json["message"].stringValue))
                    } else {
                        completion?(CustomNetworkingResponse(status: 500, message: "An unkown error occurred"))
                    }
                }
                
                task.resume()
            } else {
                completion?(CustomNetworkingResponse(status: 500, message: "Current user could not be verified"))
            }
        }
    }
}
