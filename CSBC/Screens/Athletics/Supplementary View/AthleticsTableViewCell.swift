//
//  AthleticsTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 2/21/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

///Contains properties for cells in Athetlics View, and can add data to them given and AthleticsModel and index
class AthleticsTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var levelLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!
    
    func addData(model: AthleticsModel, index: Int) {
        let charactersToFilter = CharacterSet(charactersIn: ":()1234567890")
        var titleText = model.title[index]
        titleText = titleText.components(separatedBy: charactersToFilter).joined()
        titleLabel.text = titleText
        levelLabel.text = model.level[index]
        timeLabel.text = model.time[index]
    }

}
