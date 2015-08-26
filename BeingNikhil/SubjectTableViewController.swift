//
//  SubjectTableViewController.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class SubjectTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate{
    // Retreive the managedObjectContext from AppDelegate
    @IBOutlet var subjectView: UITableView!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var subjects = [NSManagedObject]()
    var routeID = NSManagedObjectID()
    
    let subjectSegueIdentifier = "subjectSegue"
    var subjectIDToSend = NSManagedObjectID()

    var storeDrive = Bool()
    let unwindSegueIdentifier = "unwindSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(storeDrive)
        let route = managedObjectContext!.objectWithID(routeID) as! Route
        if storeDrive {
            title = "Select Route to Save Drive"
        } else {
            title = route.name + "'s Subjects"
        }
        fetchSubject()
    }
        
    func fetchSubject() {
        let route = managedObjectContext!.objectWithID(routeID) as! Route
        let predicate = NSPredicate(format: "route == %@", route)
        let fetchRequest = NSFetchRequest(entityName: "Subject")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Subject] {
            subjects = fetchResults
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let subject = subjects[indexPath.row] as! Subject
        let fetchRequest = NSFetchRequest(entityName: "Drive")
        let predicate = NSPredicate(format: "subject == %@", subject)
        fetchRequest.predicate = predicate
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Drive] {
            println("Drives Fetched")
            cell.detailTextLabel?.text = "Drives: \(fetchResults.count)"
        }
        cell.textLabel!.text = subject.valueForKey("name") as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the Drive object the user is trying to delete
            let subjectToDelete = subjects[indexPath.row] as! Subject
            
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(subjectToDelete)
            
            // Refresh the table view to indicate that it's deleted
            self.fetchSubject()
            
            // Tell the table view to animate out that row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let subject = subjects[row] as! Subject
        subjectIDToSend = subject.objectID
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if storeDrive {
            sharedMotion.drive.subject = subject
            //sharedMotion.drive.setValue(subject, forKey: "subject")
            performSegueWithIdentifier(unwindSegueIdentifier, sender: cell)
        } else {
            performSegueWithIdentifier(subjectSegueIdentifier, sender: cell)
        }
    }
    
    func unwindSegue() {
        performSegueWithIdentifier(unwindSegueIdentifier, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == subjectSegueIdentifier {
            let navVC = segue.destinationViewController as! UINavigationController
            let driveVC = navVC.viewControllers.first as! DriveTableViewController
            driveVC.subjectID = subjectIDToSend
            driveVC.storeDrive = storeDrive
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let addItemAlertViewTag = 0
    let addItemTextAlertViewTag = 1
    
    @IBAction func addSubject(sender: AnyObject) {
        let titlePrompt = UIAlertController(title: "Enter Subject Name", message: "Enter Name", preferredStyle: .Alert)
        var titleTextField: UITextField?
        titlePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "Name"
        }
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",style: .Default,
            handler: { (action) -> Void in
                if let textField = titleTextField {
                    self.saveNewSubject(textField.text)
                }
        }))
        
        self.presentViewController(titlePrompt,
            animated: true,
            completion: nil)
        
    }
    
    func saveNewSubject(title : String) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let entity =  NSEntityDescription.entityForName("Subject", inManagedObjectContext: managedContext)
        let subject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        subject.setValue(title, forKey: "name")
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }  
        let route = managedObjectContext!.objectWithID(routeID) as! Route
        subject.setValue(route, forKey: "route")
        subjects.append(subject)
        self.tableView.reloadData()
    }


    
}