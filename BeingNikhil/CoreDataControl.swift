//
//  CoreDataControl.swift
//  BeingNikhil
//
//  Extension for NSManagedObject to add objects in to-many to to-many relations
//
//  Created by Michael Tucker on 8/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData

extension NSManagedObject {
    func addObject(value: NSManagedObject, forKey: String) {
        let items = self.mutableSetValueForKey(forKey);
        items.addObject(value)
    }
}
