//
//  SubjectTableViewController.swift
//  BeingNikhil
//
//  This view controller displays all of the subjects for the selected route
//
//  Created by Michael P Tucker on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

/// Table View to display subjects for the selected Route
/// For more methods and variables see TableViewSuperClass
class SubjectTableViewController: TableViewSuperClass, UITableViewDataSource, UITableViewDelegate{
    
    /// Segue ID to transition to drive view controller
    let driveSegueIdentifier = "driveSegue"
    
    /// Segue ID to transition back to main view controller
    let unwindSegueIdentifier = "unwindSegue"
    
    /// Overriden predicate description to determine drives of the subject
    override var cellPredicateDescritpion: String {
        get {return "subject == %@"}
        set {super.cellPredicateDescritpion}
    }
    
    /// Overriden subtitlte to determine the sub-object of the subject for the cell subtitle
    override var cellSubtitleEntity: String {
        get {return "Drive"}
        set {super.cellSubtitleEntity}
    }
    
    /// Initializes view, changing title based on storing drives or not, fetches subjects
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
    
    /// Fetches subjects for the given route, sorted by name and stores in coreDataArray
    func fetchSubjects() {
        fetchCoreData("Subject", predicateDescription: "route == %@", predicateObject: managedObjectContext!.objectWithID(sharedView.routeID) as! Route, sortAttribute: "name")
    }
    
    /// Allows for deletion of subject entities, and proceeds to delete all sub-entities of the selected subject
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            deleteSubjectData(coreDataArray[indexPath.row] as! Subject)
            appDelegate.saveContext()
            self.fetchSubjects()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    /// Grabs the selected subject, if storing drive, the drive will be assigned to the subject
    /// then segue to main view controller, otherwise it moves to the drive menu
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let subject = coreDataArray[indexPath.row] as! Subject
        sharedView.subjectID = subject.objectID
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if sharedView.storeDrive {
            sharedMotion.drive.subject = subject
            performSegueWithIdentifier(unwindSegueIdentifier, sender: cell)
        } else {
            performSegueWithIdentifier(driveSegueIdentifier, sender: cell)
        }
    }
    
    /// Creates new subject entity when add button pressed, links subject to route
    @IBAction func addSubject(sender: AnyObject) {
        let route = managedObjectContext!.objectWithID(sharedView.routeID) as! Route
        addEntity("Subject", attributes: [route, "Route"], predicateDescription: "route == %@", predicateObject: route)
    }
    
}