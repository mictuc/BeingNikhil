//
//  Turn.swift
//  BeingNikhil
//
//  Turn core data object
//
//  Created by Michael P Tucker on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

class Turn: NSManagedObject {
    /// Sensor data in a String format
    @NSManaged var dataString: String

    /// Drive this turn was taken in
    @NSManaged var drive: Drive

    /// Duration of the turn in seconds
    @NSManaged var duration: NSNumber

    /// Raw data from the gyroscopes and accelerometers
    @NSManaged var sensorData: AnyObject

    /// Turn number in drive
    @NSManaged var turnNumber: NSNumber
    
    /// Starting location of the turn
    @NSManaged var startLocation: AnyObject

    /// Ending location of the turn
    @NSManaged var endLocation: AnyObject

    /// Starting timestamp of the turn
    @NSManaged var startTime: NSDate

    /// Ending timestamp of the turn
    @NSManaged var endTime: NSDate

    
    /**
    Creates a csv–formatted String with the Turn's data
    
    :returns: String csv formatted data
    */
    func csv() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm:ss a"
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
