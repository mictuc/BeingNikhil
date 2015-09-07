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
class MapViewController: UIViewController, MKMapViewDelegate {
    
    /// Map view to have route displayed on
    @IBOutlet weak var mapView: MKMapView!
    
//    /// Name of route displayed
//    var routeName = String()
    
    /// radius in meters of starting view
    let regionRadius: CLLocationDistance = 1000
    
    /// Initializes view controller and displays route on map
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        let initialLocation = sharedView.locations[0]
        centerMapOnLocation(initialLocation)
        var coordinates = sharedView.locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polyline = MKPolyline(coordinates: &coordinates, count: sharedView.locations.count)
        self.mapView.addOverlay(polyline)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blueColor()
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }

    
    /// Centers the map on the center location with regionRadius radius
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}