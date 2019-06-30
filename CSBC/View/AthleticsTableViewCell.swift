//
//  AthleticsTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 2/21/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class AthleticsTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func addData(model: AthleticsModel, index: Int) {
        let charactersToFilter : CharacterSet = CharacterSet(charactersIn: ":()1234567890")
        var titleText : String = "\(model.gender[index])'s \(model.sport[index]) \(model.homeGame[index]) \(model.opponent[index])"
        titleText = titleText.components(separatedBy: charactersToFilter).joined()
        titleLabel.text = titleText
        levelLabel.text = model.level[index]
        timeLabel.text = model.time[index]
    }

}
