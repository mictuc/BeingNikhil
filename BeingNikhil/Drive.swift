//
//  Drive.swift
//  BeingNikhil
//
//  Created by David M Sirkin on 5/12/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

class Drive: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var locations: NSOrderedSet
    @NSManaged var turns: NSOrderedSet
    @NSManaged var turnCount: NSNumber
    @NSManaged var subject: Subject


}
