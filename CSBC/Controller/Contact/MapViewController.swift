//
//  MapViewController.swift
//  CSBC
//
//  Created by Luke Redmore on 3/5/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var givenLatitude : Double = 0.000
    var givenLongitude : Double = 0.000
    let locationDictionary : [String:[Double]] = ["Seton Catholic Central":[42.098485, -75.928579], "All Saints School":[42.100491, -76.050103], "St. John's School":[42.092430, -75.908342], "St. James School":[42.115512, -75.969542]]
    let schoolsArray = ["Seton Catholic Central","St. John's School","All Saints School","St. James School"]
    var schoolSelected = 0
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let header = schoolsArray[schoolSelected]
        givenLatitude = locationDictionary[header]![0]
        givenLongitude = locationDictionary[header]![1]
        let initialLocation = CLLocation(latitude: givenLatitude, longitude: givenLongitude)
        centerMapOnLocation(location: initialLocation)
        let annotation = MapAnnotation(title: header,
                                       discipline: "Sculpture",
                                       coordinate: CLLocationCoordinate2D(latitude: givenLatitude, longitude: givenLongitude))
        mapView.addAnnotation(annotation)
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    
    @IBAction func directionsButtonPressed(_ sender: Any) {
        let application = UIApplication.shared
        let urlString = "http://maps.apple.com/?daddr=\(givenLatitude)+\(givenLongitude)&dirflg=d&t=m"
        application.open(URL(string: urlString)!)
        
    }
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
