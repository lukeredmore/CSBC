//
//  MapViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import MapKit


///Displays location of selected building in Apple Maps, along with an annotation and optional directions (through Maps app)
class MapViewController: CSBCViewController {
    
    @IBOutlet private var mapView: MKMapView!
    
    private var givenLatitude : Double = 0.000
    private var givenLongitude : Double = 0.000
    private let locationDictionary : [String:[Double]] = ["Seton Catholic Central":[42.098485, -75.928579], "All Saints School":[42.100491, -76.050103], "St. John's School":[42.092430, -75.908342], "St. James School":[42.115512, -75.969542]]
    private let fullSchoolsArray = ["Seton Catholic Central","St. John's School","All Saints School","St. James School"]
    
    
    //MARK: View Control
    override func viewWillAppear(_ animated: Bool) {
        let header = fullSchoolsArray[schoolSelected.ssInt]
        givenLatitude = locationDictionary[header]![0]
        givenLongitude = locationDictionary[header]![1]
        let initialLocation = CLLocation(latitude: givenLatitude, longitude: givenLongitude)
                centerMapOnLocation(initialLocation)

        let annotation = MapAnnotation(
            title: header,
            discipline: "Sculpture",
            coordinate: initialLocation.coordinate)
        mapView.addAnnotation(annotation)
    }
    
    
    private func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    
    @IBAction private func directionsButtonPressed(_ sender: Any) {
        let urlString = "http://maps.apple.com/?daddr=\(givenLatitude)+\(givenLongitude)&dirflg=d&t=m"
        UIApplication.shared.open(URL(string: urlString)!)
        
    }
    
    
    @IBAction private func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
