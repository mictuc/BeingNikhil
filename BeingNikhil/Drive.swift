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
    @NSManaged var locations: AnyObject
    @NSManaged var turns: NSOrderedSet
    @NSManaged var templates: NSOrderedSet
    @NSManaged var selected: Bool
    @NSManaged var subject: Subject
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
        return "Route:,\(subject.route.name)\n" + "Subject:,\(subject.name)\n" + "Starting Timestamp:,\(coalescedTimestamp)\n"
            + "Duration:,\(coalescedDuration)\n" + "Turn Count:,\(coalescedTurnCount)\n" + "\(coalescedTurnData)\n"
    }

}
