//
//  MapView.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/27/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    var locations = [CLLocation]()
    @IBOutlet weak var mapView: MKMapView!
    var routeName = String()
    let regionRadius: CLLocationDistance = 5000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = routeName
        let centerLongitude = (locations[0].coordinate.longitude + locations[locations.count/2].coordinate.longitude) / 2
        let centerLatitude = (locations[0].coordinate.latitude + locations[locations.count/2].coordinate.latitude) / 2
        let initialLocation = CLLocation(latitude: centerLatitude, longitude: centerLongitude)
        centerMapOnLocation(initialLocation)
        addRoute()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addRoute() {
        var coordinates = [CLLocationCoordinate2D]()
        for i in 0...locations.count-1 {
            coordinates += [CLLocationCoordinate2DMake(locations[i].coordinate.latitude, locations[i].coordinate.latitude)]
        }
        let myPolyline = MKPolyline(coordinates: &coordinates, count: Int(locations.count))
        mapView.addOverlay(myPolyline)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}