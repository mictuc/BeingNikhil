//
//  TemplateTableViewController.swift
//  BeingNikhil
//
//  Created by Michael Tucker on 8/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class TemplateTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate{
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var templates = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let route = managedObjectContext!.objectWithID(sharedView.routeID) as! Route
        title = route.name + "'s Templates"
        fetchTemplate()
    }
    
    func fetchTemplate() {
        //let route = managedObjectContext!.objectWithID(sharedView.routeID) as! Route
        let fetchRequest = NSFetchRequest(entityName: "Template")
        //let predicate = NSPredicate(format: "route == %@", route)
        //fetchRequest.predicate = predicate
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Template] {
            templates = fetchResults
        }
        println(templates.count)
        println("fetchTemplate finished")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("cell For Row called")
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let template = templates[indexPath.row] as! Template
        cell.textLabel!.text = template.name
        cell.detailTextLabel?.text = "Route: \(template.route)  Subject: \(template.subject)    # Drives: \(template.drives.count)"
        cell.accessoryType = UITableViewCellAccessoryType.None
        template.selected = false
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the Drive object the user is trying to delete
            let templateToDelete = templates[indexPath.row] as! Template
            managedObjectContext?.deleteObject(templateToDelete)
            
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            // Refresh the table view to indicate that it's deleted
            self.fetchTemplate()
            
            // Tell the table view to animate out that row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let template = templates[row] as! Template
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (cell?.accessoryType == UITableViewCellAccessoryType.Checkmark){
            cell!.accessoryType = UITableViewCellAccessoryType.None
            template.selected = false
        }else{
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            template.selected = true
        }
    }

}
