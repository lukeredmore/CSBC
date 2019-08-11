//
//  CalendarTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 3/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet var eventLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var schoolsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func addData(model: EventsModel) {
        eventLabel.text = model.event.uppercased()
        dayLabel.text = model.day
        schoolsLabel.text = model.schools
        timeLabel.text = model.time
        monthLabel.text = model.month
    }

}
