//
//  ViewController.swift
//  BeingNikhil
//
//  This is the main view controller for the being Nikhil App
//  Displays map, can record drives, and access data
//
//  Created by David M Sirkin on 5/2/15.
//  Revised by Michael P Tucker on 9/1/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import MapKit

/// Main View Controller for the app
class MainViewController: UIViewController {
    
    /// Map for the main view controller
    @IBOutlet var mapView: MKMapView!
    
    /// Label to display DTW result
    @IBOutlet var labelDTW: UILabel!
    
    /// ID for segue to store drives
    let storeDriveSegueIdentifier = "storeDriveSegue"
    
    /// ID for segue to browse data
    let fileBrowseSegueIdentifier = "fileBrowseSegue"
    
    /// ID for segue to export data
    let exportSegueIdentifier = "exportSegue"
    
    /// Monitoring device motion
    var monitor = false
    
    /**
        Initialization of the ViewController Class
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()

//        Display current path on Map?
//        let locations = sharedLocation.locations
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "monitorDeviceMotion")
        
        toolbarItems?.insert(MKUserTrackingBarButtonItem(mapView: mapView), atIndex: 0)
        
        let segmentedControl = UISegmentedControl(items: ["Standard", "Hybrid", "Satellite"])
        
        segmentedControl.addTarget(self, action: "mapType:", forControlEvents: .ValueChanged)
        segmentedControl.selectedSegmentIndex = 0
        toolbarItems?.insert(UIBarButtonItem(customView: segmentedControl as UIView), atIndex: 2)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDTW:", name: "DTW", object: nil)
    }
    
    /**
        Controls the start and stop of drive monitoring
    */
    func monitorDeviceMotion() {
        monitor = !monitor
        
        /// If monitor is started, motion monitoring starts. When stopped, motion monitoring stops
        if monitor {
            sharedMotion.startMonitoringDeviceMotion()
            navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: "monitorDeviceMotion"), animated: true)
        } else {
            sharedMotion.stopMonitoringDeviceMotion()
            navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "monitorDeviceMotion"), animated: true)
            performSegueWithIdentifier(storeDriveSegueIdentifier, sender: navigationItem.leftBarButtonItem)
        }
    }
    
    /**
    Updates the DTW label in the Main View Controller
    
    - parameter notification: to update
    */
    func updateDTW(notification: NSNotification) {
        labelDTW.text = String(format: "DTW: %.2f", sharedMotion.DTW)
    }

    /**
        Controls toggle switch for the app mode
    
        - parameter UISegmentedControl: Mode toggle button
    */
    @IBAction func modeType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sharedView.mode = .Record
        case 1:
            sharedView.mode = .Compare
        case 2:
            sharedView.mode = .Export
        default:
            break
        }
    }
    
    /**
        Controls toggle switch for the map view
        
        - parameter UISegmentedControl: Map type toggle button
    */
    @IBAction func mapType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .Standard
        case 1:
            mapView.mapType = .Hybrid
        case 2:
            mapView.mapType = .Satellite
        default:
            break
        }
    }
    
    @IBAction func fileButtonClicked(sender: AnyObject) {
        if sharedView.mode == .Export {
            performSegueWithIdentifier(exportSegueIdentifier, sender: navigationItem.rightBarButtonItem)
        } else {
            performSegueWithIdentifier(fileBrowseSegueIdentifier, sender: navigationItem.rightBarButtonItem)
        }
        
    }
    /**
    Determines whether or not the user is storing a drive or not
    
    - parameter UIStoryboardSegue: Segue about to perform
    - parameter AnyObject: Sender for the segue
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "storeDriveSegue") {
            sharedView.storeDrive = true
        } else {
            sharedView.storeDrive = false
        }
    }
    
    /**
    Unwind segue back to view controller
    
    - parameter UIStoryboardSegue: Unwind segue
    */
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
    }
}