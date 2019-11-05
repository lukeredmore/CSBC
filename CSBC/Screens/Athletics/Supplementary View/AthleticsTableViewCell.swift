//
//  AthleticsTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 2/21/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Contains properties for cells in Athetlics View, and can add data to them given and AthleticsModel and index
class AthleticsTableViewCell: UITableViewCell, DisplayInSearchableTableView {
    

    //MARK: Properties
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var levelLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!
    
    func addData<T>(_ genericModel: T) where T : Searchable {
        guard let model = genericModel as? AthleticsModel else { return }
        let charactersToFilter = CharacterSet(charactersIn: ":()1234567890")
        let titleText = model.title.components(separatedBy: charactersToFilter).joined()
        titleLabel.text = titleText
        levelLabel.text = model.level
        timeLabel.text = model.time
    }

}
