//
//  Comparison.swift
//  BeingNikhil
//
//  Created by Michael Tucker on 9/3/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

/// A defined driving course
class Comparison: NSManagedObject {
    
    /// Name for the route
    @NSManaged var name: String
    
    /// Comparison drive used in comparison
    @NSManaged var drive: Drive
    
    /// Ultimate average DTW score b/w template and drive
    @NSManaged var finalDTW: Double
    
    /// Template used in comparison
    @NSManaged var template: Template
    
    /// DTW scores for each turn-by-turn comparison
    @NSManaged var scores: AnyObject
    
    
    func csv() -> String {
        var csv = String()
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let templateDrives = template.drives.sortedArrayUsingDescriptors([sortDescriptor])
        
        let turnScores = scores as! [[Double]]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd h:mm a"
        csv += "Name:,\(name)\n"
        csv += "Route:,\(drive.subject.route.name)\n"
        csv += "Comparison Drive Subject:,\(drive.subject.name)\n"
        csv += "Drive Timestamp:,\(dateFormatter.stringFromDate(drive.timestamp))\n"
        csv += "Template Name:,\(template.name)\n"
        csv += "Template Subject:,\(template.subject.name)\n\n,"
        var templateTimes = String()
        for i in 0...templateDrives.count - 1 {
            csv += "Template Drive \(i + 1),"
            templateTimes += "\(dateFormatter.stringFromDate(templateDrives[i].timestamp)),"
        }
        csv += "\n"
        csv += "Turn Number," + templateTimes + "Turn DTW Averages\n"
        
        var turnAverages = [Double](count: drive.turns.count, repeatedValue: 0.0)
        var driveAverages = [Double](count: templateDrives.count, repeatedValue: 0.0)
        
        for i in 0...drive.turns.count - 1 {
            csv += "\(i + 1),"
            for j in 0...templateDrives.count - 1 {
                turnAverages[i] += turnScores[j][i]
                driveAverages[j] += turnScores[j][i]
                csv += "\(turnScores[j][i]),"
            }
            turnAverages[i] /= Double(templateDrives.count)
            csv += "\(turnAverages[i])\n"
        }
        csv += "Drive Averages,"
        for i in 0...templateDrives.count - 1 {
            driveAverages[i] /= Double(drive.turns.count)
            csv += "\(driveAverages[i]),"
        }
        csv += "\(finalDTW)"
        return csv
    }
    
}
