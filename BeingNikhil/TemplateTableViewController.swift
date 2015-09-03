//
//  TemplateTableViewController.swift
//  BeingNikhil
//
//  This view controller displays all of the templates for the selected route
//  Then can compare the selected drive to a template
//
//  Created by Michael Tucker on 8/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

/// Table View to display templates for the selected route
/// For more methods and variables see TableViewSuperClass
class TemplateTableViewController: TableViewSuperClass, UITableViewDataSource, UITableViewDelegate{
    
    /// Initializes the title and route then fetches template data
    override func viewDidLoad() {
        super.viewDidLoad()
        let route = managedObjectContext!.objectWithID(sharedView.routeID) as! Route
        title = route.name + "'s Templates"
        fetchTemplate()
    }
    
    /// Fetches templates for the selected route and stores it in coreDataArray
    func fetchTemplate() {
        fetchCoreData("Template", predicateDescription: "route == %@", predicateObject: managedObjectContext!.objectWithID(sharedView.routeID) as! Route, sortAttribute: "name")
    }
    
    /// Formates each cell with data from the coreDataArray
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let template = coreDataArray[indexPath.row] as! Template
        cell.textLabel!.text = template.name
        cell.detailTextLabel?.text = "Route: \(template.route.name)  Subject: \(template.subject.name)    # Drives: \(template.drives.count)"
        cell.accessoryType = UITableViewCellAccessoryType.None
        template.selected = false
        return cell
    }
    
    /// Deletes selected template
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            managedObjectContext?.deleteObject(coreDataArray[indexPath.row] as! Template)
            appDelegate.saveContext()
            self.fetchTemplate()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    /// Selects or deselects template at a given row
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let template = coreDataArray[indexPath.row] as! Template
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (cell?.accessoryType == UITableViewCellAccessoryType.Checkmark){
            cell!.accessoryType = UITableViewCellAccessoryType.None
            template.selected = false
        }else{
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            template.selected = true
        }
    }
    
    @IBAction func compareClicked(sender: AnyObject) {
        let comparisonDrives = sharedView.comparisonDrives
        var comparisonTemplates = [NSManagedObject]()
        for template in coreDataArray {
            if template.valueForKey("selected") as! Bool {
                comparisonTemplates.append(template)
            }
        }
        
        for drive in comparisonDrives {
            for template in comparisonTemplates {
                sharedMotion.compareDriveToTemplate(drive as! Drive, template: template as! Template)
            }
        }
    }

}
