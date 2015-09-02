//
//  DriveTableViewController.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DriveTableViewController: TableViewSuperClass, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var compareButton: UIBarButtonItem!
    
    var drives = [NSManagedObject]()
    var mapSegue = "Map Segue"
    var templateSegueIdentifier = "templateSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let subject = managedObjectContext!.objectWithID(sharedView.subjectID) as! Subject
        title = subject.name + "'s Drives"
        
        if sharedView.mode == .Record {
            compareButton.title = "Test Template"
        } else if sharedView.mode == .Compare {
            compareButton.title = "Compare to Template"
        }
        
        fetchDrives()
    }
    
    func fetchDrives() {
        drives = fetchCoreData("Drive", predicateDescription: "subject == %@", predicateObject: managedObjectContext!.objectWithID(sharedView.subjectID) as! Subject, sortAttribute: "timestamp")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let drive = drives[indexPath.row] as! Drive
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY h:mm a"
        cell.textLabel?.text = dateFormatter.stringFromDate(drive.timestamp)
        cell.detailTextLabel?.text = "Duration: \(drive.duration)   Turns: \(drive.turns.count)   Subject: \(drive.subject.name)    Route: \(drive.subject.route.name)"
        cell.accessoryType = UITableViewCellAccessoryType.None
        drive.selected = false
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the Drive object the user is trying to delete
            deleteDriveData(drives[indexPath.row] as! Drive)

            appDelegate.saveContext()
            
            // Refresh the table view to indicate that it's deleted
            self.fetchDrives()
            
            // Tell the table view to animate out that row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let drive = drives[row] as! Drive
        if (cell?.accessoryType == UITableViewCellAccessoryType.Checkmark){
            cell!.accessoryType = UITableViewCellAccessoryType.None
            drive.selected = false
        }else{
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            drive.selected = true
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    var exportFileURL = NSURL()
    var exportFiles = [NSURL]()
    
    func exportCSVFile(drive: Drive) {
        
        // 2
        let exportFilePath =
        NSTemporaryDirectory() + "export.csv"
        exportFileURL =
        NSURL(fileURLWithPath: exportFilePath)!
        NSFileManager.defaultManager().createFileAtPath(
            exportFilePath, contents: NSData(), attributes: nil)
        
        // 3
        var fileHandleError: NSError? = nil
        let fileHandle = NSFileHandle(forWritingToURL: exportFileURL,
            error: &fileHandleError)
        if let fileHandle = fileHandle {
            
            let csvData = drive.csv().dataUsingEncoding(
                NSUTF8StringEncoding, allowLossyConversion: false)
            fileHandle.writeData(csvData!)
            
            // 5
            fileHandle.closeFile()
            
            println("Export Path: \(exportFilePath)")
        
        } else {
            println("ERROR: \(fileHandleError)")
        }
        exportFiles.append(exportFileURL)
        
    }

    @IBAction func shareButtonClicked(sender: AnyObject) {        
        for drive in drives {
            let tempDrive = drive as! Drive
            if tempDrive.selected {
                exportCSVFile(drive as! Drive)
            }
        }
        let textToShare = "Exported Drive Data"
        var objectsToShare = [AnyObject]()
        objectsToShare.append(textToShare)
        for exportFile in exportFiles {
            objectsToShare.append(exportFile)
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
        
    }
    
    func testTemplate() {
        var templateDrives = [Drive]()
        for drive in drives {
            let tempDrive = drive as! Drive
            if tempDrive.selected {
                templateDrives.append(tempDrive)
            }
        }
        var templateScores = [Double]()
        for drive in templateDrives {
            var DTWSum = 0.0
            for secondDrive in templateDrives {
                if drive != secondDrive {
                    var averageTurnDTW = 0.0
                    for turn in drive.turns {
                        for secondTurn in secondDrive.turns {
                            if turn.valueForKey("turnNumber") as! NSNumber == secondTurn.valueForKey("turnNumber") as! NSNumber {
                                sharedMotion.dynamicTimeWarping(turn.valueForKey("sensorData") as! [Double], t: secondTurn.valueForKey("sensorData") as! [Double])
                                averageTurnDTW += sharedMotion.DTW
                            }
                        }
                    }
                    averageTurnDTW /= Double(drive.turns.count)
                    DTWSum += averageTurnDTW
                }
            }
            templateScores.append(DTWSum / Double(templateDrives.count - 1))
        }

        var alertMessage = String()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd h:mm a"
        for i in 0...templateScores.count - 1{
            alertMessage += "\(dateFormatter.stringFromDate(templateDrives[i].timestamp)): \(Double(round(1000 * templateScores[i]) / 1000))\n"
        }
        
        let testTemplateAlert = UIAlertController(title: "Template Scores", message: alertMessage, preferredStyle: .Alert)
        
        testTemplateAlert.addAction(UIAlertAction(title: "Cancel",style: .Default,
            handler: { (action) -> Void in
        }))
        
        testTemplateAlert.addAction(UIAlertAction(title: "Make Template",style: .Default,
            handler: { (action) -> Void in
                let subject = self.managedObjectContext!.objectWithID(sharedView.subjectID) as! Subject
                self.addEntity("Template", attributes: [subject, "subject", subject.route, "route"], relationships: templateDrives, relationshipType: "templates")
        }))
        
        self.presentViewController(testTemplateAlert,
            animated: true,
            completion: nil)
    }
    
    @IBAction func startSegue(sender: AnyObject) {
        if sharedView.mode == .Record {
            testTemplate()
        } else if sharedView.mode == .Compare {
            performSegueWithIdentifier(templateSegueIdentifier, sender: sender)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == mapSegue {
            sharedLocation.locations = drives[0].valueForKey("locations") as! [(CLLocation)]
            sharedView.routeID = drives[0].valueForKey("subject")!.valueForKey("Route")!.objectID
        } else if segue.identifier == templateSegueIdentifier {
            let subject = managedObjectContext!.objectWithID(sharedView.subjectID) as! Subject
            sharedView.routeID = subject.route.objectID
        }
    }
}