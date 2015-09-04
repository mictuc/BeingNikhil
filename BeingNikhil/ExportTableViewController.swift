//
//  ExportTableViewController.swift
//  BeingNikhil
//
//  Created by Michael Tucker on 9/3/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

/// TableViewController to display data to be exported
/// For more methods and variables see TableViewSuperClass
class ExportTableViewController: TableViewSuperClass, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet var exportTable: [UITableView]!
    
    //var sectionsOfData = [Int : String]()
    var data = [String : [NSManagedObject]]()
    
    let sections = [0 : "Drive", 1 : "Template", 2 : "Comparison"]
    
    var exportFileURL = NSURL()
    var exportFiles = [NSURL]()
    
    //FIX back button hiding
    /// If user is storing drive, title will be different, then fetches Routes
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    /// Fetches the Route entities from core data
    func fetchData() {
        for key in sections.keys {
            if sections[key]! != "Drive" {
                fetchCoreData(sections[key]!, sortAttribute: "name")
            } else {
                fetchCoreData(sections[key]!, sortAttribute: "timestamp")
            }
            data[sections[key]!] = coreDataArray
        }
    }
    
    @IBAction func exportData(sender: AnyObject) {
        var indexPaths = [NSIndexPath]()
        for section in 0...sections.count - 1 {
            for row in 0...data[sections[section]!]!.count - 1 {
                let cellPath = NSIndexPath(forRow: row, inSection: section)
                let cell = tableView.cellForRowAtIndexPath(cellPath)
                if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
                    indexPaths.append(cellPath)
                }
            }
        }
        println(indexPaths.count)
        
//        let indexPaths = self.tableView.indexPathsForSelectedRows()
//        for i in 0...indexPaths!.count - 1 {
//            let indexPath = indexPaths![i] as! NSIndexPath
        for indexPath in indexPaths {
            exportCSVFile(data[sections[indexPath.section]!]![indexPath.row])
        }
        let textToShare = "Exported Data Files"
        var objectsToShare = [AnyObject]()
        objectsToShare.append(textToShare)
        for exportFile in exportFiles {
            objectsToShare.append(exportFile)
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func exportCSVFile(entity: NSManagedObject) {
        /// Change Name of file!!!
        let exportFilePath = NSTemporaryDirectory() + "export.csv"
        exportFileURL = NSURL(fileURLWithPath: exportFilePath)!
        NSFileManager.defaultManager().createFileAtPath(exportFilePath, contents: NSData(), attributes: nil)
        var fileHandleError: NSError? = nil
        let fileHandle = NSFileHandle(forWritingToURL: exportFileURL, error: &fileHandleError)
        if let fileHandle = fileHandle {
            var csvData = NSData()
            if entity.isKindOfClass(Template) {
                let tempEntity = entity as! Template
                csvData = tempEntity.csv().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            } else if entity.isKindOfClass(Drive) {
                let tempEntity = entity as! Drive
                csvData = tempEntity.csv().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            } else {
                let tempEntity = entity as! Comparison
                csvData = tempEntity.csv().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            }
            fileHandle.writeData(csvData)
            fileHandle.closeFile()
            println("Export Path: \(exportFilePath)")
        } else {
            println("ERROR: \(fileHandleError)")
        }
        exportFiles.append(exportFileURL)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[sections[section]!]!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]!
    }
        
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]!
        let entity = data[section]![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        if section == "Drive" {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd h:mm a"
            var title = String()
            title += "Route: "
            title += entity.valueForKey("subject")!.valueForKey("route")!.valueForKey("name") as! String
            title += "   Subject: "
            title += entity.valueForKey("subject")!.valueForKey("name") as! String
            cell.textLabel!.text = title
            var subtitle = String()
            subtitle += "Time: "
            subtitle += dateFormatter.stringFromDate(entity.valueForKey("timestamp") as! NSDate)
            subtitle += "   Duration: "
            subtitle += String(Int(entity.valueForKey("duration") as! NSNumber))
            subtitle += "   Turns: "
            subtitle += String(entity.valueForKey("turns")!.count)
            cell.detailTextLabel!.text = subtitle
        } else if section == "Template" {
            cell.textLabel!.text = entity.valueForKey("name") as? String
            var subtitle = String()
            subtitle += "Route: "
            subtitle += entity.valueForKey("route")!.valueForKey("name") as! String
            subtitle += "   Subject: "
            subtitle += entity.valueForKey("subject")!.valueForKey("name") as! String
            cell.detailTextLabel!.text = subtitle
        } else {
            cell.textLabel!.text = entity.valueForKey("name") as? String
            var subtitle = String()
            subtitle += "Route: "
            subtitle += entity.valueForKey("drive")!.valueForKey("subject")!.valueForKey("route")!.valueForKey("name") as! String
            subtitle += "   Comparison Subject: "
            subtitle += entity.valueForKey("drive")!.valueForKey("subject")!.valueForKey("name") as! String
            subtitle += "   Template: "
            subtitle += entity.valueForKey("template")!.valueForKey("name") as! String
            cell.detailTextLabel!.text = subtitle
        }
        return cell
    }

    /// Selects or deselects an object at a given row
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (cell!.selected){
            cell!.accessoryType = UITableViewCellAccessoryType.None
            cell!.selected = false
        }else{
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell!.selected = true
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            let section = sections[indexPath.section]!
            if section == "Drive" {
                deleteDriveData(data[section]![indexPath.row] as! Drive)
            } else {
                managedObjectContext?.deleteObject(data[section]![indexPath.row])
            }
            appDelegate.saveContext()
            self.fetchData()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }



}
