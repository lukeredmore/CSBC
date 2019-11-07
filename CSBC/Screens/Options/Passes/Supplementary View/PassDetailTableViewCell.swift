//
//  PassDetailTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 11/6/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class PassDetailTableViewCell: UITableViewCell, DisplayInSearchableTableView {
    
    func addData<T>(_ genericModel: T) where T : Searchable {
        guard let model = genericModel as? StudentStatus else { return }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        textLabel?.text = timeFormatter.string(from: model.time)
        detailTextLabel?.text = model.location.replacingOccurrences(of: "Signed ", with: "")
    }
    

    
}
