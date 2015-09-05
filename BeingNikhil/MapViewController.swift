//
//  MapView.swift
//  BeingNikhil
//
//  Map view to display the route taken by a given drive
//
//  Created by Michael P Tucker on 8/27/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import MapKit
import CoreData

/// View controller to display route of given drive on map
class MapViewController: UIViewController {
    
    /// Locations of the route
    var locations = [CLLocation]()
    
    /// Map view to have route displayed on
    @IBOutlet weak var mapView: MKMapView!
    
    /// Name of route displayed
    var routeName = String()
    
    /// radius in meters of starting view
    let regionRadius: CLLocationDistance = 1000
    
    /// Initializes view controller and displays route on map
    override func viewDidLoad() {
        super.viewDidLoad()
        locations = sharedLocation.locations
        title = routeName
//        let centerLongitude = (locations[0].coordinate.longitude + locations[locations.count/2].coordinate.longitude) / 2
//        let centerLatitude = (locations[0].coordinate.latitude + locations[locations.count/2].coordinate.latitude) / 2
//        let initialLocation = CLLocation(latitude: centerLatitude, longitude: centerLongitude)
        let initialLocation = locations[0]
        centerMapOnLocation(initialLocation)
        addRoute()
    }
    
    /// Centers the map on the center location with regionRadius radius
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    /// Creates and overlays route on map
    func addRoute() {
        var coordinates = [CLLocationCoordinate2D]()
        for i in 0...locations.count-1 {
            //println(i)
            coordinates.append(CLLocationCoordinate2DMake(locations[i].coordinate.latitude, locations[i].coordinate.latitude))
        }
        let geodesic = MKGeodesicPolyline(coordinates: &coordinates[0], count: locations.count)
        self.mapView.addOverlay(geodesic)

//        let myPolyline = MKPolyline(coordinates: &coordinates, count: Int(locations.count))
//        mapView.addOverlay(myPolyline)
    }

}