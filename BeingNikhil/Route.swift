//
//  Route.swift
//  BeingNikhil
//
//  Route core data object
//
//  Created by Michael P Tucker on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

/// A defined driving course
class Route: NSManagedObject {
    
    /// Name for the route
    @NSManaged var name: String
    
    /// Drivers who drove this route
    @NSManaged var subjects: NSOrderedSet
    
    /// Templates made using this route
    @NSManaged var templates: NSOrderedSet

    
}
