//
//  Drive.swift
//  BeingNikhil
//
//  Drive core data object
//
//  Created by David M Sirkin on 5/12/15.
//  Revised by Michael P Tucker on 9/1/15
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

/// An recorded driving event with turns
class Drive: NSManagedObject {
    
    /// Duration of the drive in seconds
    @NSManaged var duration: NSNumber
    
    /// The stored locations of the drive as an [CLLocation]
    @NSManaged var locations: AnyObject
    
    /// Templates the drive is a part of
    @NSManaged var templates: NSOrderedSet
    
    /// Time the drive started
    @NSManaged var timestamp: NSDate
    
    /// Turn events during the drive
    @NSManaged var turns: NSOrderedSet
    
    /// Subject who drove the drive
    @NSManaged var subject: Subject
    
    /**
        Creates a csv–formatted String with the Drive's data
    
        - returns: String csv formatted data
    */
    func csv() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        let coalescedTimestamp = dateFormatter.stringFromDate(timestamp)
        let coalescedDuration = duration
        let coalescedTurnCount = String(turns.count)
        var coalescedTurnData = String()
        var turnMap = [Int:Turn]()
        
        for turn in self.turns {
            let tempTurn = turn as! Turn
            turnMap[Int(tempTurn.turnNumber)] = turn as? Turn
        }
        
        for var i = 1; i <= turns.count; i++ {
            coalescedTurnData += turnMap[i]!.csv()
        }
        
        return "Route:,\(subject.route.name),Subject:,\(subject.name)\n" + "Starting Timestamp:,\(coalescedTimestamp),"
            + "Duration:,\(coalescedDuration),Turn Count:,\(coalescedTurnCount)\n" + "Turn Number,Start Time,End Time, Duration,"
            + "Start Latitude,Start Longitude,Start Speed,End Latitude,End Longitude,End Speed,Raw Data\n" + "\(coalescedTurnData)\n"
    }

}
