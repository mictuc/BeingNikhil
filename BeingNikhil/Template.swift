//
//  Template.swift
//  BeingNikhil
//
//  Template core data object
//
//  Created by Michael P Tucker on 8/27/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

/// A series of drives to which one can compare drives.
class Template: NSManagedObject {
    
    /// Drives used in the template
    @NSManaged var drives: NSOrderedSet
    
    /// Scores for each drive used in template
    @NSManaged var driveScores: String

    /// Name of the template
    @NSManaged var name: String
    
    /// Route used by the template
    @NSManaged var route: Route
    
    /// Selected variable for tableView purposes
    @NSManaged var selected: Bool
    
    /// Subject who drove the drives in the template
    @NSManaged var subject: Subject

    func csv() -> String {
        var csv = String()
        csv += "Name:,\(name)\n" + "Subject:,\(subject.name)\n" + "Route:,\(route.name)\n"
        for drive in drives {
            let tempDrive = drive as! Drive
            csv += tempDrive.csv()
            csv += "/n"
        }
        return csv
    }
    
}
