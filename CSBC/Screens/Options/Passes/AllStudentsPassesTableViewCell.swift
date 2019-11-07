//
//  AllStudentsPassesTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 11/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class AllStudentsPassesTableViewCell: UITableViewCell, DisplayInSearchableTableView {
    func addData<T>(_ genericModel: T) where T : Searchable {
        guard let model = genericModel as? StudentPassInfo else { return }
        textLabel?.text = model.name
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
