//
//  DriveTableViewController.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/20/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DriveTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var compareButton: UIBarButtonItem!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var drives = [NSManagedObject]()
    var subjectID = NSManagedObjectID()
    var mapSegue = "Map Segue"
    var templateSegueIdentifier = "templateSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
        title = subject.name + "'s Drives"
        
        if sharedView.mode == .Record {
            compareButton.title = "Test Template"
        } else if sharedView.mode == .Compare {
            compareButton.title = "Compare to Template"
        }
        
        fetchDrive()
    }
    
    func fetchDrive() {
        let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
        let predicate = NSPredicate(format: "subject == %@", subject)
        let fetchRequest = NSFetchRequest(entityName: "Drive")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Drive] {
            drives = fetchResults
        }
        println(drives.count)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drives.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let drive = drives[indexPath.row] as! Drive
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY h:mm a"
        cell.textLabel?.text = dateFormatter.stringFromDate(drive.timestamp)
        cell.detailTextLabel?.text = "Duration: \(drive.duration)   Turns: \(drive.turns.count)   Subject: \(drive.subject.name)    Route: \(drive.subject.route.name)"
        cell.accessoryType = UITableViewCellAccessoryType.None
        drive.selected = false
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the Drive object the user is trying to delete
            let driveToDelete = drives[indexPath.row] as! Drive
            
            let turns = driveToDelete.turns
            for turn in turns {
                managedObjectContext?.deleteObject(turn as! NSManagedObject)
            }
            let templates = driveToDelete.templates
            for template in templates {
                managedObjectContext?.deleteObject(template as! NSManagedObject)
            }
            
            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(driveToDelete)
            
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            // Refresh the table view to indicate that it's deleted
            self.fetchDrive()
            
            // Tell the table view to animate out that row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let drive = drives[row] as! Drive
        if (cell?.accessoryType == UITableViewCellAccessoryType.Checkmark){
            cell!.accessoryType = UITableViewCellAccessoryType.None
            drive.selected = false
        }else{
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            drive.selected = true
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    var exportFileURL = NSURL()
    var exportFiles = [NSURL]()
    
    func exportCSVFile(drive: Drive) {
        
        // 2
        let exportFilePath =
        NSTemporaryDirectory() + "export.csv"
        exportFileURL =
        NSURL(fileURLWithPath: exportFilePath)!
        NSFileManager.defaultManager().createFileAtPath(
            exportFilePath, contents: NSData(), attributes: nil)
        
        // 3
        var fileHandleError: NSError? = nil
        let fileHandle = NSFileHandle(forWritingToURL: exportFileURL,
            error: &fileHandleError)
        if let fileHandle = fileHandle {
            
            let csvData = drive.csv().dataUsingEncoding(
                NSUTF8StringEncoding, allowLossyConversion: false)
            fileHandle.writeData(csvData!)
            
            // 5
            fileHandle.closeFile()
            
            println("Export Path: \(exportFilePath)")
        
        } else {
            println("ERROR: \(fileHandleError)")
        }
        exportFiles.append(exportFileURL)
        
    }

    @IBAction func shareButtonClicked(sender: AnyObject) {        
        for drive in drives {
            let tempDrive = drive as! Drive
            if tempDrive.selected {
                exportCSVFile(drive as! Drive)
            }
        }
        let textToShare = "Exported Drive Data"
        var objectsToShare = [AnyObject]()
        objectsToShare.append(textToShare)
        for exportFile in exportFiles {
            objectsToShare.append(exportFile)
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
        
    }
    
    func testTemplate() {
        var templateDrives = [Drive]()
        for drive in drives {
            let tempDrive = drive as! Drive
            if tempDrive.selected {
                templateDrives.append(tempDrive)
            }
        }
        var templateScores = [Double]()
        for drive in templateDrives {
            var DTWSum = 0.0
            for secondDrive in templateDrives {
                if drive != secondDrive {
                    var averageTurnDTW = 0.0
                    for turn in drive.turns {
                        for secondTurn in secondDrive.turns {
                            if turn.valueForKey("turnNumber") as! NSNumber == secondTurn.valueForKey("turnNumber") as! NSNumber {
                                sharedMotion.dynamicTimeWarping(turn.valueForKey("sensorData") as! [Double], t: secondTurn.valueForKey("sensorData") as! [Double])
                                averageTurnDTW += sharedMotion.DTW
                            }
                        }
                    }
                    averageTurnDTW /= Double(drive.turns.count)
//                    println(averageTurnDTW)
                    DTWSum += averageTurnDTW
                }
            }
            templateScores.append(DTWSum / Double(templateDrives.count - 1))
        }
//        println("finished comparison")

        var alertMessage = String()
        for i in 0...templateScores.count - 1{
            alertMessage += "\(i+1): \(templateScores[i])\n"
        }
        
        let testTemplateAlert = UIAlertController(title: "Template Scores", message: alertMessage, preferredStyle: .Alert)
        
        testTemplateAlert.addAction(UIAlertAction(title: "Cancel",style: .Default,
            handler: { (action) -> Void in
        }))
        
        testTemplateAlert.addAction(UIAlertAction(title: "Make Template",style: .Default,
            handler: { (action) -> Void in
                self.makeTemplateAlert(templateDrives)
        }))
        
        self.presentViewController(testTemplateAlert,
            animated: true,
            completion: nil)
    }
    
    func makeTemplateAlert(templateDrives: [Drive]) {
        let namePrompt = UIAlertController(title: "Enter Template Name", message: nil, preferredStyle: .Alert)
        var nameTextField: UITextField?
        namePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            nameTextField = textField
            textField.placeholder = "Name"
        }
        
        namePrompt.addAction(UIAlertAction(title: "Cancel",style: .Default,
            handler: { (action) -> Void in
        }))
        
        namePrompt.addAction(UIAlertAction(title: "Ok",style: .Default,
            handler: { (action) -> Void in
                if let textField = nameTextField {
                    self.saveNewTemplate(textField.text, templateDrives: templateDrives)
                }
        }))
        
        self.presentViewController(namePrompt,
            animated: true,
            completion: nil)

    }
    
    func saveNewTemplate(name: String, templateDrives: [Drive]) {
        println(name)
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        println(managedContext)
        let entity =  NSEntityDescription.entityForName("Template", inManagedObjectContext: managedContext)
        let template = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        template.setValue(name, forKey: "name")
        let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
        template.setValue(subject, forKey: "subject")
        template.setValue(subject.route, forKey: "route")
        for drive in templateDrives {
            drive.addObject(template, forKey: "templates")
        }
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }        
    }
    
    @IBAction func startSegue(sender: AnyObject) {
        if sharedView.mode == .Record {
            testTemplate()
        } else if sharedView.mode == .Compare {
            performSegueWithIdentifier(templateSegueIdentifier, sender: sender)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == mapSegue {
            let navVC = segue.destinationViewController as! UINavigationController
            let mapVC = navVC.viewControllers.first as! MapViewController
            mapVC.locations = drives[0].valueForKey("locations") as! [(CLLocation)]
            mapVC.routeName = drives[0].valueForKey("subject")?.valueForKey("Route")?.valueForKey("name") as! String
        } else if segue.identifier == templateSegueIdentifier {
            let subject = managedObjectContext!.objectWithID(subjectID) as! Subject
            sharedView.routeID = subject.route.objectID
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}