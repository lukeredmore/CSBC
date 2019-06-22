//
//  MapAnnotation.swift
//  CSBC
//
//  Created by Luke Redmore on 3/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class MapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return title
    }
    
}
