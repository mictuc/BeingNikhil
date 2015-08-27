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
    
    func csv() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm:ss a"
//                let coalescedTimestamp = dateFormatter.stringFromDate(timestamp)  ?? ""
        let coalescedTurnCount = turnNumber.stringValue
        let coalescedStartTime = dateFormatter.stringFromDate(startTime)
        let coalescedEndTime = dateFormatter.stringFromDate(endTime)
        let coalescedDuration = duration
        let coalescedStartLocation = startLocation.description
        let coalescedEndLocation = endLocation.description
        let coalescedTurnData = dataString
        return "\(coalescedTurnCount),\(coalescedStartTime),\(coalescedTurnCount),\(coalescedDuration),"
            + "\(coalescedStartLocation),\(coalescedEndLocation),\(coalescedTurnData)\n"
    }
    
}
