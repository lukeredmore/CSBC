//
//  STEMRetriever.swift
//  CSBC
//
//  Created by Luke Redmore on 1/11/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import SwiftyJSON
import Firebase

class STEMRetriever {
    private var setDisplayed = Set<STEMTableModel>()
    private var answeredArray = [String : Bool]()
    let completion : (Set<STEMTableModel>, Bool) -> Void
    
    init(completion: @escaping (Set<STEMTableModel>, Bool) -> Void) {
        self.completion = completion
    }
    
    func retrieveSTEMArray() {
        Database.database().reference().child("STEMNight").observeSingleEvent(of: .value) { snapshot in
            guard let nightJSON = snapshot.value as? [[String : Any]] else { return }
            print("STEM array updated, new data returned")
            
            self.answeredArray = UserDefaults.standard.value(forKey:"stemAnswered") as? [String: Bool] ?? [:]
            let modelArray = self.parseDataJSON(json: JSON(nightJSON), answeredArray: self.answeredArray)
            self.saveAndDisplay(modelArray)
        }
    }
    
    func answer(for model : STEMTableModel) {
        guard var newS = setDisplayed.remove(model) else { return }
        newS.answered = true
        answeredArray[newS.identifier] = true
        UserDefaults.standard.set(answeredArray, forKey: "stemAnswered")
        setDisplayed.insert(newS)
        saveAndDisplay(setDisplayed)
    }
    
    private func saveAndDisplay(_ model : Set<STEMTableModel>) {
        setDisplayed = model
        completion(setDisplayed, false)
    }
    
    private func parseDataJSON(json : JSON, answeredArray : [String : Bool]) -> Set<STEMTableModel> {
        var setToReturn = Set<STEMTableModel>()
        var n = 0
        while n < json.count {
            let entry = json[n]
            let identifier = "\(entry["identifier"])"
            let imageIdentifier = "\(entry["imageIdentifier"])" != "null" ? "\(entry["imageIdentifier"])" : nil
            let modelToInsert = STEMTableModel(
                title: "\(entry["title"])",
                location : "\(entry["location"])",
                organization : "\(entry["organization"])",
                imageIdentifier : imageIdentifier,
                identifier: identifier,
                description : "\(entry["description"])",
                question : "\(entry["question"])",
                answer : "\(entry["answer"])",
                answered : answeredArray[identifier] ?? false
            )
            setToReturn.insert(modelToInsert)
            n += 1
        }
        return setToReturn
    }
}

