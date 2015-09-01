//
//  TableViewController.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/18/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class RouteTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate{
    // Retreive the managedObjectContext from AppDelegate
    @IBOutlet var routeView: UITableView!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var routes = [NSManagedObject]()
    let routeSegueIdentifier = "routeSegue"
    var routeIDToSend = NSManagedObjectID()

    
    //FIX back button hiding...
    override func viewDidLoad() {
        super.viewDidLoad()
        if sharedView.storeDrive {
            //self.navigationItem.hidesBackButton = true
            title = "Select Route to Save Drive"
        } else {
//            self.navigationItem.hidesBackButton = false
            title = "Routes"
        }

        fetchRoute()
    }
    
    func fetchRoute() {
        let fetchRequest = NSFetchRequest(entityName: "Route")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Route] {
            routes = fetchResults
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
            let route = routes[indexPath.row]
            cell.textLabel!.text = route.valueForKey("name") as? String
            let predicate = NSPredicate(format: "route == %@", route)
            let fetchRequest = NSFetchRequest(entityName: "Subject")
            fetchRequest.predicate = predicate
            if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Subject] {
                println("Subjects Fetched")
                cell.detailTextLabel?.text = "Subjects: \(fetchResults.count)"
            }
        
            return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the Drive object the user is trying to delete
            let routeToDelete = routes[indexPath.row] as! Route
            let subjects = routeToDelete.subjects
            for subject in subjects {
                let tempSubject = subject as! Subject
                let drives = tempSubject.drives
                for drive in drives {
                    let driveToDelete = drive as! Drive
                    let turns = driveToDelete.turns
                    for turn in turns {
                        managedObjectContext?.deleteObject(turn as! NSManagedObject)
                    }
                    let templates = driveToDelete.templates
                    for template in templates {
                        managedObjectContext?.deleteObject(template as! NSManagedObject)
                    }
                    managedObjectContext?.deleteObject(drive as! NSManagedObject)
                }
                managedObjectContext?.deleteObject(subject as! NSManagedObject)
            }
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(routeToDelete)
            
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }

            // Refresh the table view to indicate that it's deleted
            self.fetchRoute()
            
            // Tell the table view to animate out that row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let route = routes[row] as! Route
        route.objectID
        routeIDToSend = route.objectID
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier(routeSegueIdentifier, sender: cell)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == routeSegueIdentifier {
            let navVC = segue.destinationViewController as! UINavigationController
            let subjectVC = navVC.viewControllers.first as! SubjectTableViewController
            subjectVC.routeID = routeIDToSend
            //subjectVC.storeDrive = storeDrive
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let addItemAlertViewTag = 0
    let addItemTextAlertViewTag = 1

    @IBAction func addRoute(sender: AnyObject) {
        let namePrompt = UIAlertController(title: "Enter Route Name",
            message: nil,
            preferredStyle: .Alert)
        
        var titleTextField: UITextField?
        namePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "Name"
        }
        
        namePrompt.addAction(UIAlertAction(title: "Cancel",
            style: .Default,
            handler: { (action) -> Void in
        }))

        namePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                if let textField = titleTextField {
                    self.saveNewRoute(textField.text)
                }
        }))
        
        self.presentViewController(namePrompt,
            animated: true,
            completion: nil)
    }
    
    func saveNewRoute(title : String) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let entity =  NSEntityDescription.entityForName("Route", inManagedObjectContext: managedContext)
        let route = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        route.setValue(title, forKey: "name")
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }  
        routes.append(route)
        self.tableView.reloadData()
    }

}
