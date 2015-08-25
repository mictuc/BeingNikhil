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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Routes"
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
            fetchRoute()
    }
    
    func fetchRoute() {
        let fetchRequest = NSFetchRequest(entityName: "Route")
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
            return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the Drive object the user is trying to delete
            let routeToDelete = routes[indexPath.row]
            
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(routeToDelete)
            
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
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let addItemAlertViewTag = 0
    let addItemTextAlertViewTag = 1

    @IBAction func addRoute(sender: AnyObject) {
        let titlePrompt = UIAlertController(title: "Enter Route Name",
            message: "Enter Text",
            preferredStyle: .Alert)
        
        var titleTextField: UITextField?
        titlePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "Name"
        }
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                if let textField = titleTextField {
                    self.saveNewRoute(textField.text)
                }
        }))
        
        self.presentViewController(titlePrompt,
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
    

    
    /*let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Drive")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Drive] {
            
            // Create an Alert, and set it's message to whatever the itemText is
            let alert = UIAlertController(title: "date: \(fetchResults[0].timestamp)",
                message: "duration: \(fetchResults[0].duration)",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            
            // Display the alert
            self.presentViewController(alert,
                animated: true,
                completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }*/

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
