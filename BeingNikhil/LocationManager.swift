//
//  LocationManager.swift
//  BeingNikhil
//
//  Created by David M Sirkin on 5/2/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    var locations = [CLLocation]()
    
    override init() {
        super.init()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            // self.locations.append(location)
        }
    }
}
let sharedLocation = LocationManager()