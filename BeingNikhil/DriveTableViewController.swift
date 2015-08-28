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

class DriveTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var shareButton: UIBarButtonItem!
    // Retreive the managedObjectContext from AppDelegate

    @IBOutlet var DriveView: UITableView!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var drives = [NSManagedObject]()
    var subjectID = NSManagedObjectID()
    var unwindSegueID = "unwindSegue"
    var mapSegue = "Map Segue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
        title = subject.name + "'s Drives"
        fetchDrive()
    }
    
    func unwindSegue() {
        performSegueWithIdentifier(unwindSegueID, sender: self)
    }
    
    func fetchDrive() {
        let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
        //let predicate = NSPredicate(format: "subject == %@", subject)
        let fetchRequest = NSFetchRequest(entityName: "Drive")
        //fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Drive] {
            drives = fetchResults
        }
        println(drives.count)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drives.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        //        let cellIdentifier = "Cell"
//        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        let drive = drives[indexPath.row] as! Drive
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        cell.textLabel?.text = dateFormatter.stringFromDate(drive.timestamp)
//        cell.textLabel?.text = "Duration: \(drive.duration)"
//        cell.textLabel?.text = "\(drive.duration)"
//        cell.detailTextLabel?.text = "Test"
        cell.detailTextLabel?.text = "Duration: \(drive.duration)   Turns: \(drive.turns.count)   Subject: \(drive.subject.name)    Route: \(drive.subject.route.name)"
        //println(drive.timestamp)
//        println(drive.subject)
        
        if drive.selected {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark;
            //UITableViewCellAccessoryType.
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None;
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the Drive object the user is trying to delete
            let driveToDelete = drives[indexPath.row] as! Drive
            
            let turns = driveToDelete.turns
            for turn in turns {
                managedObjectContext?.deleteObject(turn as! NSManagedObject)
            }
//            let locations = driveToDelete.locations
//            for location in locations {
//                managedObjectContext?.deleteObject(location as! NSManagedObject)
//            }
            
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(driveToDelete)
            
            // Refresh the table view to indicate that it's deleted
            self.fetchDrive()
            
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
//            let csvAlert = UIAlertController(title: "Enter Subject Name", message: drive.csv(), preferredStyle: .Alert)
//            
//            csvAlert.addAction(UIAlertAction(title: "Ok",style: .Default,
//                handler: { (action) -> Void in
//            }))
//            
//            self.presentViewController(csvAlert,
//                animated: true,
//                completion: nil)
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
            
            // 4
//            for turn in
//            for turn in results! {
//                let journalEntry = object as! JournalEntry
//                
//                fileHandle.seekToEndOfFile()
                let csvData = drive.csv().dataUsingEncoding(
                    NSUTF8StringEncoding, allowLossyConversion: false)
                fileHandle.writeData(csvData!)
//            }
            
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == mapSegue {
            let navVC = segue.destinationViewController as! UINavigationController
            let mapVC = navVC.viewControllers.first as! MapView
            mapVC.locations = drives[0].valueForKey("locations") as! [(CLLocation)]
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}