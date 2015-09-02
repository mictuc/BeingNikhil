//
//  TableViewController.swift
//  BeingNikhil
//
//  This view controller displays all of the routes stored in the app
//
//  Created by Michael P Tucker on 8/18/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

/// TableViewController to display saved routes
/// For more methods and variables see TableViewSuperClass
class RouteTableViewController: TableViewSuperClass, UITableViewDataSource, UITableViewDelegate  {
        
    /// Saved routes which are displayed
    var routes = [NSManagedObject]()
    
    /// ID for segue to subjects
    let subjectSegueIdentifier = "subjectSegue"
    
    
    //FIX back button hiding
    /// If user is storing drive, title will be different, then fetches Routes
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
    
    /// Fetches the Route entities from core data
    func fetchRoutes() {
        fetchCoreData("Route", sortAttribute: "name")
    }
    
    /// Allows user to delete route, then proceeds to delete all data related to route
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            deleteRouteData(coreDataArray[indexPath.row] as! Route)
            appDelegate.saveContext()
            self.fetchRoutes()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    /// Selects the cell and route the user selected, and passes the routeID to sharedView then performs segue to Subject View
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let route = coreDataArray[indexPath.row] as! Route
        sharedView.routeID = route.objectID
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier(subjectSegueIdentifier, sender: cell)
    }

    /// Creates new Route object
    @IBAction func addRoute(sender: AnyObject) {
        addEntity("Route", attributes: [])
    }
}
