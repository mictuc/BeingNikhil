//
//  SegmentedControl.swift
//  BeingNikhil
//
//  Extension for UIAlertController to adjust the map settings
//
//  Created by David M Sirkin on 5/11/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func addSegmentedControl(sender: AnyObject, action: Selector) {
        let frame = sender.frame
        
        let segmentedControl = UISegmentedControl(items: ["Standard", "Hybrid", "Satellite"])
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.frame = CGRect(x: frame.midX - 100, y: frame.minY + 6, width: 200, height: 29)
        
        segmentedControl.addTarget(sender, action: action, forControlEvents: .ValueChanged)
        
        self.view.addSubview(segmentedControl)
    }
}