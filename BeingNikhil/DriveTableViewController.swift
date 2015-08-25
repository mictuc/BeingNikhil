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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
        title = subject.name + " Drives"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        fetchDrive()
    }
    
    func fetchDrive() {
        let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
        let predicate = NSPredicate(format: "subject == %@", subject)
        let fetchRequest = NSFetchRequest(entityName: "Drive")
        fetchRequest.predicate = predicate
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Drive] {
            drives = fetchResults
        }
        print(drives.count)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drives.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let drive = drives[indexPath.row] as! Drive
        cell.textLabel?.text = "Date: \(drive.timestamp)"
        cell.detailTextLabel?.text = "Duration: \(drive.duration)"
        
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
        if (cell?.accessoryType == UITableViewCellAccessoryType.Checkmark){
            cell!.accessoryType = UITableViewCellAccessoryType.None;
        }else{
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark;
        }
        let drive = drives[row] as! Drive
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}