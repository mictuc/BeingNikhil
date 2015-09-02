//
//  TemplateTableViewController.swift
//  BeingNikhil
//
//  Created by Michael Tucker on 8/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class TemplateTableViewController: TableViewSuperClass, UITableViewDataSource, UITableViewDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let route = managedObjectContext!.objectWithID(sharedView.routeID) as! Route
        title = route.name + "'s Templates"
        fetchTemplate()
    }
    
    func fetchTemplate() {
        fetchCoreData("Template", predicateDescription: "route == %@", predicateObject: managedObjectContext!.objectWithID(sharedView.routeID) as! Route, sortAttribute: "name")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let template = coreDataArray[indexPath.row] as! Template
        cell.textLabel!.text = template.name
        cell.detailTextLabel?.text = "Route: \(template.route.name)  Subject: \(template.subject.name)    # Drives: \(template.drives.count)"
        cell.accessoryType = UITableViewCellAccessoryType.None
        template.selected = false
        return cell
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            managedObjectContext?.deleteObject(coreDataArray[indexPath.row] as! Template)
            
            appDelegate.saveContext()
            
            // Refresh the table view to indicate that it's deleted
            self.fetchTemplate()
            
            // Tell the table view to animate out that row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let template = coreDataArray[row] as! Template
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
