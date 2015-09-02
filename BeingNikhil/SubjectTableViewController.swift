//
//  SubjectTableViewController.swift
//  BeingNikhil
//
//  
//
//  Created by Michael P Tucker on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class SubjectTableViewController: TableViewSuperClass, UITableViewDataSource, UITableViewDelegate{
    
    var subjects = [NSManagedObject]()
    
    let driveSegueIdentifier = "driveSegue"
    let unwindSegueIdentifier = "unwindSegue"
    
    override var cellPredicateDescritpion: String {
        get {return "subject == %@"}
        set {super.cellPredicateDescritpion}
    }
    
    override var cellSubtitleEntity: String {
        get {return "Drive"}
        set {super.cellSubtitleEntity}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let route = managedObjectContext!.objectWithID(sharedView.routeID) as! Route
        if sharedView.storeDrive {
            title = "Select Subject to Save Drive"
        } else {
            title = route.name + "'s Subjects"
        }
        fetchSubjects()
    }
        
    func fetchSubjects() {
        fetchCoreData("Subject", predicateDescription: "route == %@", predicateObject: managedObjectContext!.objectWithID(sharedView.routeID) as! Route, sortAttribute: "name")
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            deleteSubjectData(coreDataArray[indexPath.row] as! Subject)
            
            appDelegate.saveContext()
            
            // Refresh the table view to indicate that it's deleted
            self.fetchSubjects()
            
            // Tell the table view to animate out that row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let subject = coreDataArray[row] as! Subject
        sharedView.subjectID = subject.objectID
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if sharedView.storeDrive {
            sharedMotion.drive.subject = subject
            performSegueWithIdentifier(unwindSegueIdentifier, sender: cell)
        } else {
            performSegueWithIdentifier(driveSegueIdentifier, sender: cell)
        }
    }
        
    @IBAction func addSubject(sender: AnyObject) {
        let route = managedObjectContext!.objectWithID(sharedView.routeID) as! Route
        addEntity("Subject", attributes: [route, "Route"], predicateDescription: "route == %@", predicateObject: route)
    }
    
}