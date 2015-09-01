//
//  CoreDataControl.swift
//  BeingNikhil
//
//  Created by Michael Tucker on 8/31/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreData
extension NSManagedObject {
    func addObject(value: NSManagedObject, forKey: String) {
        var items = self.mutableSetValueForKey(forKey);
        items.addObject(value)
    }
}