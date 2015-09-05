//
//  LocationManager.swift
//  BeingNikhil
//
//  Manages the apps location data
//
//  Created by David M Sirkin on 5/2/15.
//  Revised by Michael P Tucker on 9/1/15
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreLocation

/// Manages apps location data
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    /// Manager for the LocationManager class
    let manager = CLLocationManager()
    
    /// Array of CLLocations to be used by other classes
    var locations = [CLLocation]()
    
    ///Initializes self
    override init() {
        super.init()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    /// Updates locations
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.locations.append(location)
        }
    }
}

/// LocationManager object to be used in other classes
let sharedLocation = LocationManager()