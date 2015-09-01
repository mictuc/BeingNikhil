//
//  Template.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/27/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

class Template: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var drives: NSOrderedSet
    @NSManaged var route: Route
    @NSManaged var subject: Subject
    @NSManaged var selected: Bool
    
}
