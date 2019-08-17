//
//  CalendarTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 3/2/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet private var eventLabel: UILabel!
    @IBOutlet private var dayLabel: UILabel!
    @IBOutlet private var monthLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var schoolsLabel: UILabel!
    
    func addData(model: EventsModel) {
        let date = Calendar.current.date(from: model.date)
        
        eventLabel.text = model.event.uppercased()
        dayLabel.text = date?.dayString()
        monthLabel.text = date?.monthAbbreviationString().uppercased()
        timeLabel.text = model.time
        schoolsLabel.text = model.schools
    }
}
