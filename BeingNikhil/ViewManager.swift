//
//  ViewManager.swift
//  BeingNikhil
//
//  Created by DesignX Lab2 on 8/27/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

class ViewManager: NSObject {
    enum Mode {
        case Record
        case Compare
        case Export
    }
    var mode = Mode.Record

    var storeDrive = false
}

let sharedView = ViewManager()