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
//    @NSManaged var turnCount: NSNumber
    @NSManaged var selected: Bool
    @NSManaged var subject: Subject
    func csv() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        let coalescedTimestamp = dateFormatter.stringFromDate(timestamp)  ?? ""
        let coalescedDuration = duration  ?? ""
        let coalescedTurnCount = String(turns.count) ?? ""
        var coalescedTurnData = String() ?? ""
        for turn in self.turns {
            let tempTurn = turn as! Turn
            
            coalescedTurnData += tempTurn.turnNumber.stringValue ?? ""
            coalescedTurnData += ","
            coalescedTurnData += tempTurn.dataString ?? ""
            coalescedTurnData += ","
        }
        return "\(coalescedTimestamp),\(coalescedDuration)," +
            "\(coalescedTurnCount),\(coalescedTurnData)\n"
    }

}
