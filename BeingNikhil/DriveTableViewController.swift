//
//  DriveTableViewController.swift
//  BeingNikhil
//
//  This view controller displays all of the drives for the selected route
//  Addtionally, it can test/make template, and display route on a map
//
//  Created by Michael P Tucker on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

/// Table View to display drives for the selected subject
/// For more methods and variables see TableViewSuperClass
class DriveTableViewController: TableViewSuperClass, UITableViewDataSource, UITableViewDelegate {
    
    /// Button on toolbar to test/make template or compare drive to template
    @IBOutlet var compareButton: UIBarButtonItem!
    
    /// Segue ID to transition to map view of drive's route
    var mapSegue = "Map Segue"
    
    /// Segue ID to transition to table view of templates for route
    var templateSegueIdentifier = "templateSegue"
    
    /// Initializes view with title and labels compareButton, also fetches drives
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
    
    /// Fetches subjects for the given route, sorted by name and stores in coreDataArray
    func fetchDrives() {
        fetchCoreData("Drive", predicateDescription: "subject == %@", predicateObject: managedObjectContext!.objectWithID(sharedView.subjectID) as! Subject, sortAttribute: "timestamp")
    }
    
    /// Formats the cells with the data from coreDataArray
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let drive = coreDataArray[indexPath.row] as! Drive
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY h:mm a"
        cell.textLabel?.text = dateFormatter.stringFromDate(drive.timestamp)
        cell.detailTextLabel?.text = "Duration: \(drive.duration)   Turns: \(drive.turns.count)   Subject: \(drive.subject.name)    Route: \(drive.subject.route.name)"
        cell.accessoryType = UITableViewCellAccessoryType.None
        drive.selected = false
        return cell
    }
    
    /// Allows deletion of drive objects and their related sub-entities
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            deleteDriveData(coreDataArray[indexPath.row] as! Drive)
            appDelegate.saveContext()
            self.fetchDrives()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    /// When a cell is selected, it indicates that the drive is selected, can also unselect
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let drive = coreDataArray[indexPath.row] as! Drive
        if (cell?.accessoryType == UITableViewCellAccessoryType.Checkmark){
            cell!.accessoryType = UITableViewCellAccessoryType.None
            drive.selected = false
        }else{
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            drive.selected = true
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    /// When compareButton is pressed will either test selected drives in template or segue to template view
    @IBAction func compareButtonPressed(sender: AnyObject) {
        if sharedView.mode == .Record {
            testTemplate()
        } else if sharedView.mode == .Compare {
            performSegueWithIdentifier(templateSegueIdentifier, sender: sender)
        }
    }

    /// Tests the selected drives as a template by running DTW between every pair of drives and takes the average of the average of the DTW for each turn of the drive as the final score for each selected drive, then displays scores in alert view
    func testTemplate() {
        var templateDrives = [Drive]()
        for drive in coreDataArray {
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
                self.addEntity("Template", attributes: [subject, "subject", subject.route, "route", alertMessage, "driveScores"], relationships: templateDrives, relationshipType: "templates")
        }))
        
        self.presentViewController(testTemplateAlert,
            animated: true,
            completion: nil)
    }
    
    /// If segue is going to map, sets data for route to be displayed, otherwise segues to template view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == mapSegue {
            sharedLocation.locations = coreDataArray[0].valueForKey("locations") as! [(CLLocation)]
            sharedView.routeID = coreDataArray[0].valueForKey("subject")!.valueForKey("Route")!.objectID
        } else if segue.identifier == templateSegueIdentifier {
            let subject = managedObjectContext!.objectWithID(sharedView.subjectID) as! Subject
            sharedView.routeID = subject.route.objectID
        }
    }
    
    
    ///EXPORT TO CSV STUFF–––TO MOVE!
    var exportFileURL = NSURL()
    var exportFiles = [NSURL]()
    
    func exportCSVFile(drive: Drive) {
        let exportFilePath = NSTemporaryDirectory() + "export.csv"
        exportFileURL = NSURL(fileURLWithPath: exportFilePath)!
        NSFileManager.defaultManager().createFileAtPath(exportFilePath, contents: NSData(), attributes: nil)
        var fileHandleError: NSError? = nil
        let fileHandle = NSFileHandle(forWritingToURL: exportFileURL, error: &fileHandleError)
        if let fileHandle = fileHandle {
            let csvData = drive.csv().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            fileHandle.writeData(csvData!)
            fileHandle.closeFile()
            println("Export Path: \(exportFilePath)")
        } else {
            println("ERROR: \(fileHandleError)")
        }
        exportFiles.append(exportFileURL)
    }
    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        for drive in coreDataArray {
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

}