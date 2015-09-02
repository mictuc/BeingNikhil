//
//  TableViewController.swift
//  BeingNikhil
//
//  Route view controller for app
//
//  Created by Michael P Tucker on 8/18/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

/// TableViewController to display saved routes
class RouteTableViewController: TableViewSuperClass, UITableViewDataSource, UITableViewDelegate  {
        
    /// Saved routes which are displayed
    var routes = [NSManagedObject]()
    
    /// ID for segue to subjects
    let subjectSegueIdentifier = "subjectSegue"
    
    
    //FIX back button hiding...
    override func viewDidLoad() {
        super.viewDidLoad()
        if sharedView.storeDrive {
            self.navigationItem.hidesBackButton = true
            title = "Select Route to Save Drive"
        } else {
            self.navigationItem.hidesBackButton = false
            title = "Routes"
        }

        fetchRoutes()
    }
    
    func fetchRoutes() {
        fetchCoreData("Route", sortAttribute: "name")
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the Drive object the user is trying to delete
            deleteRouteData(coreDataArray[indexPath.row] as! Route)
            appDelegate.saveContext()
            
            // Refresh the table view to indicate that it's deleted
            self.fetchRoutes()
            
            // Tell the table view to animate out that row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let route = coreDataArray[row] as! Route
        sharedView.routeID = route.objectID
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier(subjectSegueIdentifier, sender: cell)
    }

    
    @IBAction func addRoute(sender: AnyObject) {
        addEntity("Route", attributes: [])
    }
}
