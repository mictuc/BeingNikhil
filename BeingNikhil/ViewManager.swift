//
//  ViewManager.swift
//  BeingNikhil
//
//  Created by Michael P Tucker on 8/27/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation
import CoreData

class ViewManager: NSObject {
    enum Mode {
        case Record
        case Compare
        case Export
    }
    var mode = Mode.Record

    var storeDrive = false
    
    var routeID = NSManagedObjectID()
    
    var subjectID = NSManagedObjectID()
}

let sharedView = ViewManager()