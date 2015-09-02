//
//  Subject.swift
//  BeingNikhil
//
//  Subject core data object
//
//  Created by Michael P Tucker on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

/// Driver of a route
class Subject: NSManagedObject {
    
    /// The drives this driver has driven on this route
    @NSManaged var drives: NSOrderedSet

    /// Name of the driver
    @NSManaged var name: String
    
    /// Route taken by driver
    @NSManaged var route: Route
    
    /// Templates made of this driver
    @NSManaged var templates: NSOrderedSet
    
    
}
