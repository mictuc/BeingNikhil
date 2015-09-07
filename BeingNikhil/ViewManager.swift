//
//  ViewManager.swift
//  BeingNikhil
//
//  Manager for view controllers
//
//  Created by Michael P Tucker on 8/27/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData
import CoreLocation

/// Manager for view controllers
class ViewManager: NSObject {
    
    /// Different settings of app
    enum Mode {
        case Record
        case Compare
        case Export
    }
    
    /// mode to indicate which setting the app is in
    var mode = Mode.Record

    /// Whether or not the user is storing a drive
    var storeDrive = false
    
    /// The ID of the latest route selected
    var routeID = NSManagedObjectID()
    
    /// The ID of the latest subject selected
    var subjectID = NSManagedObjectID()
    
    /// The array of drives to compare to a template
    var comparisonDrives = [NSManagedObject]()
    
    var locations = [CLLocation]()
}

/// ViewManager object to be used by other classes
let sharedView = ViewManager()