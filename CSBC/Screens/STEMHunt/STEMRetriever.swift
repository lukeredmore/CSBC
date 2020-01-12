//
//  STEMRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 1/11/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import SwiftyJSON

class STEMRetriever {
    private let preferences = UserDefaults.standard
    private var setDisplayed = Set<STEMTableModel>()
    let completion : (Set<STEMTableModel>, Bool) -> Void
    
    init(completion: @escaping (Set<STEMTableModel>, Bool) -> Void) {
        self.completion = completion
    }
    
    func retrieveSTEMArray() {
        print("Attempting to retrieve stored STEM data.")
        if let json = preferences.value(forKey:"stemArray") as? Data,
            let stemArray = try? PropertyListDecoder().decode(Set<STEMTableModel>.self, from: json) {
            saveAndDisplay(stemArray)
        }
        else {
            print("No local STEM data found in UserDefaults. Looking online.")
            saveAndDisplay(STEMRetriever.getBlankData())
            return
        }
    }
    
    func toggle(for model : STEMTableModel) {
        guard var newS = setDisplayed.remove(model) else { return }
        newS.answered = !newS.answered
        setDisplayed.insert(newS)
        saveAndDisplay(setDisplayed)
    }
    
    private func saveAndDisplay(_ model : Set<STEMTableModel>) {
        setDisplayed = model
        print("STEM array is being added to UserDefaults")
        UserDefaults.standard.set(try? PropertyListEncoder().encode(setDisplayed), forKey: "stemArray")
        completion(setDisplayed, false)
    }
    
    private static func getBlankData() -> Set<STEMTableModel> {
        let path = Bundle.main.path(forResource: "STEMInfo", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let json = try! JSON(data: data)
        
        var setToReturn = Set<STEMTableModel>()
        var n = 0
        while n < json.count {
            let entry = json[n]
            let modelToInsert = STEMTableModel(
                title: "\(entry["title"])",
                location : "\(entry["location"])",
                organization : "\(entry["organization"])",
                imageIdentifier : "\(entry["imageIdentifier"])",
                description : "\(entry["description"])",
                question : "\(entry["question"])",
                answer : "\(entry["answer"])",
                answered : false
            )
            setToReturn.insert(modelToInsert)
            n += 1
        }
        return setToReturn
    }
}

