//
//  Subject.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

class Subject: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var numDrives: NSNumber
    @NSManaged var drives: NSOrderedSet
    @NSManaged var route: Route
    
    
}
