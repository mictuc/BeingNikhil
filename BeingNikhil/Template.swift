//
//  Template.swift
//  BeingNikhil
//
//  Template core data object
//
//  Created by Michael P Tucker on 8/27/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

/// A series of drives to which one can compare drives.
class Template: NSManagedObject {
    
    /// Drives used in the Template
    @NSManaged var drives: NSOrderedSet

    /// Name of the template
    @NSManaged var name: String
    
    /// Route used by the template
    @NSManaged var route: Route
    
    /// Selected variable for tableView purposes
    @NSManaged var selected: Bool
    
    /// Subject who drove the drives in the template
    @NSManaged var subject: Subject

    
}
