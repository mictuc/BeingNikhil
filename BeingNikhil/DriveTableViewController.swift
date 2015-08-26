//
//  DriveTableViewController.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class DriveTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate{
    // Retreive the managedObjectContext from AppDelegate

    @IBOutlet var DriveView: UITableView!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var drives = [NSManagedObject]()
    var subjectID = NSManagedObjectID()
    var storeDrive = Bool()
    var unwindSegueID = "unwindSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
        
        title = subject.name + "'s Drives"

        if storeDrive {
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            let entity =  NSEntityDescription.entityForName("Drive", inManagedObjectContext: managedContext)
            let drive = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
//            let date = sharedMotion.startMonitoringDate
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
//            drive.setValue("Date: \(dateFormatter.stringFromDate(date))", forKey: "timestamp")
            drive.setValue(sharedMotion.startMonitoringDate, forKey: "timestamp")
            drive.setValue(NSDate().timeIntervalSinceDate(sharedMotion.startMonitoringDate), forKey: "duration")
            drive.setValue(false, forKey: "selected")
            drive.setValue(sharedMotion.turnCount, forKey: "turnCount")
            let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
            drive.setValue(subject, forKey: "subject")
            for turn in sharedMotion.turnArray {
                turn.drive = managedObjectContext!.objectWithID(drive.objectID) as! Drive
            }
            drives.append(drive)
            self.tableView.reloadData()
//
//            let route = subject.route
//            let saveAlert = UIAlertController(title: "Drive Saved", message: "Route: \(route.name); Subject: \(subject.name)", preferredStyle: .Alert)
//            saveAlert.addAction(UIAlertAction(title: "Ok",style: .Default,
//                handler: { (action) -> Void in
////                    self.tableView.reloadData()
//                    //self.unwindSegue()
//            }))
//            self.presentViewController(saveAlert,
//                animated: true,
//                completion: nil)
            
        } else {
            //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            fetchDrive()
        }
        
    }
    
    func unwindSegue() {
        performSegueWithIdentifier(unwindSegueID, sender: self)
    }
    
    func fetchDrive() {
        let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
        let predicate = NSPredicate(format: "subject == %@", subject)
        let fetchRequest = NSFetchRequest(entityName: "Drive")
        fetchRequest.predicate = predicate
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
        cell.detailTextLabel?.text = "Duration: \(drive.duration)   Turns: \(drive.turns.count)   Subject: \(drive.subject.name)"
        //println(drive.timestamp)
//        println(drive.subject)
        
        if drive.selected {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark;
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
            
            let csvAlert = UIAlertController(title: "Enter Subject Name", message: drive.csv(), preferredStyle: .Alert)
            
            csvAlert.addAction(UIAlertAction(title: "Ok",style: .Default,
                handler: { (action) -> Void in
            }))
            
            self.presentViewController(csvAlert,
                animated: true,
                completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}