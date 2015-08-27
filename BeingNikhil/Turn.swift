//
//  Turn.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

class Turn: NSManagedObject {
    
    @NSManaged var sensorData: AnyObject
    @NSManaged var drive: Drive
    @NSManaged var turnNumber: NSNumber
    @NSManaged var dataString: String
    @NSManaged var startTime: NSDate
    @NSManaged var endTime: NSDate
    @NSManaged var duration: NSNumber
    @NSManaged var startLocation: AnyObject
    @NSManaged var endLocation: AnyObject
    
    func csv() {
        
    }
    
}
