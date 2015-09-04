//
//  TableViewSuperClass.swift
//  BeingNikhil
//
//  Super class for BeingNikhil table view controllers
//  managing many of the common methods and variables used
//
//  Created by Michael Tucker on 9/1/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//


import UIKit
import CoreData

/// Super class to be implemented by table view controllers
class TableViewSuperClass: UITableViewController {
    
    /// AppDelegate to manage data and processes for the app
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    /// Manager for core data objects
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    /// Array for core data objects
    var coreDataArray = [NSManagedObject]()
    
    /// ID for cells
    let cellID = "Cell"
    
    /// Sorting attribute for core data entities
    var cellSortingAttribute: String {
        return "name"
    }
    
    /// Predicate description to determine subtitle of cells
    var cellPredicateDescritpion: String {
        return "route == %@"
    }
    
    /// Entity type for subtitle count
    var cellSubtitleEntity: String {
        return "Subject"
    }
    
    /**
        Fetches core data entities from the app based on the passed in parameters
        then sets coreDataArray to results
    
        :param: entityName Name of entity type to fetch results for
        :param: predicateDescription Description of predicate to filter fetch results––default is ""
        :param: predicateObject Object to compare with predicate description––default is nil
        :param: sortAttribute Attribute by which to sort fetch results
    */
    func fetchCoreData(entityName: String, predicateDescription: String = "", predicateObject: NSManagedObject? = nil, sortAttribute: String) {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        if predicateDescription != "" {
            let predicate = NSPredicate(format: predicateDescription, predicateObject!)
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortAttribute, ascending: true)]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            coreDataArray = fetchResults
        }
    }

    /** 
        Determines how many cells are needed in table view controller
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataArray.count
    }
    
    /**
        Sets the cells to be editable
    */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    /**
        Formats cells based on coreDataArray, cellSubtitleEntity, and cellPredicateDescription
    */
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
    
    /**
        Prompts user for name for new core data entity then creates and stores entity
    
        :param: entityType Name for entity type to add
        :param: attributes Array of attributes to be added to array in format [value, key, value, key,...]
        :param: predicateDescription String description of predicate to filter when redisplaying data
        :param: predicateObject Object to compare to predicateDescription when redisplaying data
        :param: relationships Array of objects to be added to relation of new entity
        :param: relationshipType Name of relationship for relationships to be added to
    */
    func addEntity(entityType: String, attributes: [AnyObject], predicateDescription: String? = nil, predicateObject: NSManagedObject? = nil, relationships: [NSManagedObject]? = nil, relationshipType: String? = nil) {
        let namePrompt = UIAlertController(title: "Enter \(entityType) Name", message: nil, preferredStyle: .Alert)
        
        var nameTextField: UITextField?
        namePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            nameTextField = textField
            textField.placeholder = "Name"
        }
        
        namePrompt.addAction(UIAlertAction(title: "Cancel", style: .Default,
            handler: { (action) -> Void in
        }))
        
        namePrompt.addAction(UIAlertAction(title: "Ok", style: .Default,
            handler: { (action) -> Void in
                if let textField = nameTextField {
                    self.saveEntity(entityType, name: textField.text, attributes: attributes, predicateDescription: predicateDescription, predicateObject: predicateObject, relationships: relationships, relationshipType: relationshipType)
                }
        }))
        
        self.presentViewController(namePrompt, animated: true,completion: nil)
    }
    
    /**
        Creates and saves new core entity based on passed in parameters
    
        :param: entityType Name for entity type to add
        :param: name Name for new entity
        :param: attributes Array of attributes to be added to array in format [value, key, value, key,...]
        :param: predicateDescription String description of predicate to filter when redisplaying data
        :param: predicateObject Object to compare to predicateDescription when redisplaying data
        :param: relationships Array of objects to be added to relation of new entity
        :param: relationshipType Name of relationship for relationships to be added to
    */
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
        } else if entityType != "Template" && entityType != "Comparison" {
            fetchCoreData(entityType, predicateDescription: predicateDescription!, predicateObject: predicateObject, sortAttribute: cellSortingAttribute)
            self.tableView.reloadData()
        }
    }
    
    func getSelectedCells() -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        for row in 0...coreDataArray.count - 1 {
            let cellPath = NSIndexPath(forRow: row, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(cellPath)
            if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
                indexPaths.append(cellPath)
            }
        }
        return indexPaths
    }

    /**
        Deletes a passed in drive, and its turns and templates
    
        :param: drive Drive to be deleted with its turns and templates
    */
    func deleteDriveData(drive: Drive){
        for turn in drive.turns {
            managedObjectContext?.deleteObject(turn as! NSManagedObject)
        }
        for template in drive.templates {
            managedObjectContext?.deleteObject(template as! NSManagedObject)
        }
        managedObjectContext?.deleteObject(drive)
    }
    
    /**
        Deletes a passed in subject and its drives
    
        :param: subject Subject to be deleted with its drives
    */
    func deleteSubjectData(subject: Subject) {
        for drive in subject.drives {
            deleteDriveData(drive as! Drive)
        }
        managedObjectContext?.deleteObject(subject)
    }
    
    /**
        Deletes a passed in route and its subjects
    
        :param: route Route to be deleted with its subjects
    */
    func deleteRouteData(route: Route) {
        for subject in route.subjects {
            deleteSubjectData(subject as! Subject)
        }
        managedObjectContext?.deleteObject(route)
    }
    
}
