//
//  ContactInfoMapCell.swift
//  CSBC
//
//  Created by Luke Redmore on 3/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class ContactInfoMapCell: UITableViewCell {

    @IBOutlet var mapImageView: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var buildingLabel: UILabel!
    
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override  func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
