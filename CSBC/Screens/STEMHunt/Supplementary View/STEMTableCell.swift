//
//  STEMTableCell.swift
//  CSBC
//
//  Created by Luke Redmore on 1/11/20.
//  Copyright © 2020 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class STEMTableCell: UITableViewCell, DisplayInSearchableTableView {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    func addData<T>(_ genericModel: T) where T : Searchable {
        guard let model = genericModel as? STEMTableModel else { return }
        titleLabel.text = model.title
        organizationLabel.text = model.organization
        let logoName = model.imageIdentifier == nil ? model.identifier : model.imageIdentifier!
        logoImageView.image = UIImage(named: "\(logoName)logo") ?? UIImage(named: "lettermark")
        checkImageView.image = model.answered ? UIImage(named: "check") : UIImage(named: "uncheck")
        selectionStyle = .none
    }
    
}
