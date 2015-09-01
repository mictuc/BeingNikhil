//
//  Route.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

class Route: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var numSubjects: NSNumber
    @NSManaged var subjects: NSOrderedSet
    @NSManaged var templates: NSOrderedSet

    
}
