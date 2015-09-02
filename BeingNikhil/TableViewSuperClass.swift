//
//  TableViewSuperClass.swift
//  BeingNikhil
//
//  Created by Michael Tucker on 9/1/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//


import UIKit
import CoreData

/// TableViewController to display saved routes
class TableViewSuperClass: UITableViewController {
    
    /// Manager for core data objects
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var coreDataArray = [NSManagedObject]()
    
    let cellID = "Cell"
    var cellSortingAttribute: String {
        return "name"
    }
    var cellPredicateDescritpion: String {
        return "route == %@"
    }
    var cellSubtitleEntity: String {
        return "Subject"
    }

    
    func fetchCoreData(entityName: String, predicateDescription: String = "", predicateObject: NSManagedObject? = nil, sortAttribute: String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        if predicateDescription != "" {
            let predicate = NSPredicate(format: predicateDescription, predicateObject!)
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortAttribute, ascending: true)]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            coreDataArray = fetchResults
        }
        return coreDataArray
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataArray.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! UITableViewCell
        let entity = coreDataArray[indexPath.row]
        cell.textLabel!.text = entity.valueForKey(cellSortingAttribute) as? String
        let predicate = NSPredicate(format: cellPredicateDescritpion, entity)
        let fetchRequest = NSFetchRequest(entityName: cellSubtitleEntity)
        fetchRequest.predicate = predicate
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            cell.detailTextLabel?.text = "\(cellSubtitleEntity)s: \(fetchResults.count)"
        }
        return cell
    }
    
    func addEntity(entityType: String, attributes: [AnyObject], predicateDescription: String? = nil, predicateObject: NSManagedObject? = nil, relationships: [NSManagedObject]? = nil, relationshipType: String? = nil) {
        let namePrompt = UIAlertController(title: "Enter \(entityType) Name", message: nil, preferredStyle: .Alert)
        
        var nameTextField: UITextField?
        namePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            nameTextField = textField
            textField.placeholder = "Name"
        }
        
        namePrompt.addAction(UIAlertAction(title: "Cancel",
            style: .Default,
            handler: { (action) -> Void in
        }))
        
        namePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                if let textField = nameTextField {
                    self.saveEntity(entityType, name: textField.text, attributes: attributes, predicateDescription: predicateDescription, predicateObject: predicateObject, relationships: relationships, relationshipType: relationshipType)
                }
        }))
        
        self.presentViewController(namePrompt,
            animated: true,
            completion: nil)
    }
    
    func saveEntity(entityType: String, name: String, attributes: [AnyObject], predicateDescription: String? = nil, predicateObject: NSManagedObject? = nil, relationships: [NSManagedObject]? = nil, relationshipType: String? = nil) {
        let entity =  NSEntityDescription.entityForName(entityType, inManagedObjectContext: managedObjectContext!)
        let newEntity = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        newEntity.setValue(name, forKey: "name")
        if relationships != nil {
            for relation in relationships! {
                relation.addObject(newEntity, forKey: relationshipType!)
            }
        }
        for i in stride(from: 0, to: attributes.count, by: 2) {
            newEntity.setValue(attributes[i], forKey: attributes[i + 1] as! String)
        }
        appDelegate.saveContext()
        if entityType == "Route" {
            fetchCoreData(entityType, sortAttribute: cellSortingAttribute)
            self.tableView.reloadData()
        } else if entityType != "Template" {
            fetchCoreData(entityType, predicateDescription: predicateDescription!, predicateObject: predicateObject, sortAttribute: cellSortingAttribute)
            self.tableView.reloadData()
        }
    }

    func deleteDriveData(drive: Drive){
        for turn in drive.turns {
            managedObjectContext?.deleteObject(turn as! NSManagedObject)
        }
        for template in drive.templates {
            managedObjectContext?.deleteObject(template as! NSManagedObject)
        }
        managedObjectContext?.deleteObject(drive)
    }
    
    func deleteSubjectData(subject: Subject) {
        for drive in subject.drives {
            deleteDriveData(drive as! Drive)
        }
        managedObjectContext?.deleteObject(subject)
    }
    
    func deleteRouteData(route: Route) {
        for subject in route.subjects {
            deleteSubjectData(subject as! Subject)
        }
        managedObjectContext?.deleteObject(route)
    }
    
}
