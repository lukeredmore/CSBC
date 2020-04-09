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
    static func sendPostRequest(url urlString: String, body: [String:String], completion: ((CustomNetworkingResponse) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else { dispatch(urlString, body, nil, completion); return }

        user.getIDToken { (token, error) in
            if let error = error {
                completion?(CustomNetworkingResponse(status: 500, message: error.localizedDescription))
            } else if let token = token {
                dispatch(urlString, body, token, completion)
            } else {
                completion?(CustomNetworkingResponse(status: 500, message: "Current user could not be verified"))
            }
        }
    }
    
    private static func dispatch(_ urlString: String, _ body: [String:String], _ authToken: String? = nil, _ completion: ((CustomNetworkingResponse) -> Void)? = nil) {
        let session = URLSession.shared
        guard let url = URL(string: urlString) else {
            completion?(CustomNetworkingResponse(status: 400, message: "Invalid URL"))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = authToken {request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")}
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else { completion?(CustomNetworkingResponse(status: 400, message: "Unparseable JSON"))
            return
        }
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion?(CustomNetworkingResponse(status: 500, message: error.localizedDescription))
            } else if let response = response, let httpResponse = response as? HTTPURLResponse, let data = data, let json = try? JSON(data: data) {
                completion?(CustomNetworkingResponse(status: httpResponse.statusCode, message: json["message"].stringValue))
            } else {
                completion?(CustomNetworkingResponse(status: 500, message: "An unkown error occurred"))
            }
        }
        
        task.resume()
    }
}
