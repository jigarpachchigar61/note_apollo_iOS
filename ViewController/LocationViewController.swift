//
//  LocationViewController.swift
//  note_apollo_iOS
//
//  Created by Nency on 31/01/21.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var noteLocation: [String:CLLocationCoordinate2D] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.isZoomEnabled = true
        
        clearAllAnnotaion()
        noteLocation.forEach { (noteLocation) in
            markLocation(noteLocation.value, noteLocation.key)
        }
    }
    
    
    func markLocation(_ coordinate: CLLocationCoordinate2D, _ title: String){
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinate
        
        let latDelta: CLLocationDegrees = 0.01
        let lngDelta: CLLocationDegrees = 0.01
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func clearAllAnnotaion(){
        mapView.annotations.forEach { (annotation) in
            mapView.removeAnnotation(annotation)
        }
    }
}

extension LocationViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
        
    }
}
