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
    
    let sections = [1 : "Drives", 2 : "Templates", 3 : "Comparisons"]
    
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
            fetchCoreData(sections[key]!, sortAttribute: "name")
            data[sections[key]!] = coreDataArray
        }
    }
    
    @IBAction func exportData(sender: AnyObject) {
        let indexPaths = self.tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        for indexPath in indexPaths {
            //exportCSVFile(data[sections[indexPath.section]!]![indexPath.row])
        }
        /// Share...
    }
    
    func exportCSVFile(drive: Drive) {
        let exportFilePath = NSTemporaryDirectory() + "export.csv"
        exportFileURL = NSURL(fileURLWithPath: exportFilePath)!
        NSFileManager.defaultManager().createFileAtPath(exportFilePath, contents: NSData(), attributes: nil)
        var fileHandleError: NSError? = nil
        let fileHandle = NSFileHandle(forWritingToURL: exportFileURL, error: &fileHandleError)
        if let fileHandle = fileHandle {
            let csvData = drive.csv().dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            fileHandle.writeData(csvData!)
            fileHandle.closeFile()
            println("Export Path: \(exportFilePath)")
        } else {
            println("ERROR: \(fileHandleError)")
        }
        exportFiles.append(exportFileURL)
    }
    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        for drive in coreDataArray {
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

    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[sections[section]!]!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]!
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject] {
        var indexTitles = [String]()
        for i in 1...3 {
            indexTitles.append(sections[i]!)
        }
        return indexTitles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]!
        let entity = data[section]![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        if section == "Drives" {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd h:mm a"
            var title = String()
            title += "Route: "
            title += entity.valueForKey("subject")!.valueForKey("route")!.valueForKey("name") as! String
            title += "   Subject: "
            title += entity.valueForKey("subject")!.valueForKey("name") as! String
            title += "   Time: "
            title += dateFormatter.stringFromDate(entity.valueForKey("timestamp") as! NSDate)
            cell.textLabel!.text = title
            var subtitle = String()
            subtitle += "Duration: "
            subtitle += String(Int(entity.valueForKey("duration") as! NSNumber))
            subtitle += "   Turns: "
            subtitle += String(entity.valueForKey("turns")!.count)
            cell.detailTextLabel!.text = subtitle
        } else if section == "Templates" {
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
            subtitle += entity.valueForKey("drive")!.valueForKey("route")!.valueForKey("name") as! String
            subtitle += "   Comparison Subject: "
            subtitle += entity.valueForKey("drive")!.valueForKey("subject")!.valueForKey("name") as! String
            subtitle += "   Template: "
            subtitle += entity.valueForKey("template")!.valueForKey("name") as! String
            cell.detailTextLabel!.text = subtitle
        }
        return cell
    }



}
