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
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    /// Name of route displayed
    var routeName = String()
    
    /// radius in meters of starting view
    let regionRadius: CLLocationDistance = 1000
    
    /// Initializes view controller and displays route on map
    override func viewDidLoad() {
        super.viewDidLoad()
        let drive = managedObjectContext!.objectWithID(sharedView.driveID) as! Drive
        let locations = drive.locations as! [CLLocation]
        title = drive.subject.route.name
        self.mapView.delegate = self
        let initialLocation = locations[0]
        centerMapOnLocation(initialLocation)
        var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        self.mapView.addOverlay(polyline)
        
        for turn in drive.turns {
            let tempTurn = turn as! Turn
            let turnPin = MKPointAnnotation()
            let startLocation = tempTurn.startLocation as! CLLocation
            turnPin.coordinate = startLocation.coordinate
            turnPin.title = "Turn #\(tempTurn.turnNumber)"
            turnPin.subtitle = "Start Location"
            mapView.addAnnotation(turnPin)
            let turnPin2 = MKPointAnnotation()
            let endLocation = tempTurn.endLocation as! CLLocation
            turnPin2.coordinate = endLocation.coordinate
            turnPin2.title = "Turn #\(tempTurn.turnNumber)"
            turnPin2.subtitle = "End Location"
            mapView.addAnnotation(turnPin2)
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blueColor()
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            //view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            if annotation.subtitle! == "End Location" {
                view.pinTintColor = UIColor.redColor()
            } else {
                view.pinTintColor = UIColor.greenColor()
            }
        }
        return view
    }

    
    /// Centers the map on the center location with regionRadius radius
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}