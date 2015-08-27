//
//  ViewController.swift
//  BeingNikhil
//
//  Created by David M Sirkin on 5/2/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var label: UILabel!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let storeDriveSegueIdentifier = "storeDriveSegue"
    
    @IBOutlet weak var turnLabel: UILabel!
    enum Mode {
        case Store
        case Match
    }
    var mode = Mode.Store
    var monitor = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let locations = sharedLocation.locations
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "monitorDeviceMotion")
        
        toolbarItems?.insert(MKUserTrackingBarButtonItem(mapView: mapView), atIndex: 0)
        
        let segmentedControl = UISegmentedControl(items: ["Standard", "Hybrid", "Satellite"])
        
        segmentedControl.addTarget(self, action: "mapType:", forControlEvents: .ValueChanged)
        segmentedControl.selectedSegmentIndex = 0
        
        toolbarItems?.insert(UIBarButtonItem(customView: segmentedControl as UIView), atIndex: 2)
        
        //let button: AnyObject = UIButton.buttonWithType(.DetailDisclosure)
        //button.addTarget(self, action: "displayAlertController:", forControlEvents: .TouchUpInside)
        
        //toolbarItems?.insert(UIBarButtonItem(customView: button as! UIView), atIndex: 2)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDTW:", name: "DTW", object: nil)
    }
    /*
    func displayAlertController(sender: AnyObject) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
        
        alertController.popoverPresentationController?.sourceView = sender as! UIView
        alertController.addSegmentedControl(self, action: "mapType:")
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    */
    func updateDTW(notification: NSNotification) {
        label.text = String(format: "DTW: %.2f", sharedMotion.DTW)
    }
    
    func turnStarted(notification: NSNotification) {
        turnLabel.text = "Turn Started"
    }
    
    func turnEnded(notification: NSNotification) {
        turnLabel.text = "Turn Ended"
    }
    
    func monitorDeviceMotion() {
        monitor = !monitor
        
        if monitor {
            sharedMotion.startMonitoringDeviceMotion()
            navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: "monitorDeviceMotion"), animated: true)
        } else {
            sharedMotion.stopMonitoringDeviceMotion()
            navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "monitorDeviceMotion"), animated: true)
            performSegueWithIdentifier(storeDriveSegueIdentifier, sender: navigationItem.leftBarButtonItem)
        }
    }
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "storeDriveSegue") {
            sharedView.storeDrive = true
        } else {
            sharedView.storeDrive = false
        }
    }
    
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
}

let mainView = ViewController()