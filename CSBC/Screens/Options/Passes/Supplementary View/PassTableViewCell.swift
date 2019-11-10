//
//  PassTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 10/23/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class PassTableViewCell: UITableViewCell, DisplayInSearchableTableView {
    func addData<T>(_ genericModel: T) where T : Searchable {
        guard let student = genericModel as? SignedOutStudentPassInfo else { return }
        nameLabel.text = student.name + " (\(student.gradeLevel))"
        locationLabel.text = student.currentStatus.location

        let interval = Date().timeIntervalSince(student.currentStatus.time)
        let timeString = interval.stringFromTimeInterval()
        timeLabel.text = timeString
    }
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

}
