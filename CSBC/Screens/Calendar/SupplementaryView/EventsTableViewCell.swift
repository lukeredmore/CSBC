//
//  EventsTableViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 11/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell, DisplayInSearchableTableView {
    
    func addData<T>(_ genericModel: T) where T : Searchable {
        guard let model = genericModel as? EventsModel else { return }
        let date = Calendar.current.date(from: model.date)
        
        eventLabel.text = model.event.uppercased()
        dayLabel.text = date?.dayString()
        monthLabel.text = date?.monthAbbreviationString().uppercased()
        timeLabel.text = model.time
        schoolsLabel.text = model.schools
    }
    
    
    @IBOutlet private var eventLabel: UILabel!
    @IBOutlet private var dayLabel: UILabel!
    @IBOutlet private var monthLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var schoolsLabel: UILabel!
    
}
