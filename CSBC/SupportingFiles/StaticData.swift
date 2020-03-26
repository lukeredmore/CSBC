//
//  StaticData.swift
//  CSBC
//
//  Created by Luke Redmore on 3/25/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import SwiftyJSON
import Firebase

class StaticData {
    private static var jsonURL : URL {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return URL(fileURLWithPath: "staticData", relativeTo: directoryURL).appendingPathExtension("json")
    }
    
    static func readData(atPath path : String) -> String?  {
        let pathAsArr = path.components(separatedBy: "/")
        do {
            let savedData = try Data(contentsOf: jsonURL)
            let savedJSON = try JSON(data: savedData)
            return savedJSON[pathAsArr].string
        } catch {
            print("Unable to read staticData.json")
            return nil
        }
    }
    
    static func getDataFromFirebase() {
        Database.database().reference(withPath: "Schools").observeSingleEvent(of: .value) { (snapshot) in
            guard let dataRetrieved = snapshot.value else { return }
            let dataJSON = JSON(dataRetrieved)
            do {
                guard let data = try? dataJSON.rawData() else {
                    print("Unable to convert json to data")
                    return
                }
                try data.write(to: jsonURL)
                print("File saved: \(jsonURL.absoluteURL)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
