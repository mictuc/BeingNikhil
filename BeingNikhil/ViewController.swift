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
    
    func monitorDeviceMotion() {
        monitor = !monitor
        
        if monitor {
            sharedMotion.startMonitoringDeviceMotion()
            navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: "monitorDeviceMotion"), animated: true)
        } else {
            sharedMotion.stopMonitoringDeviceMotion()
            routeAlert()
            navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "monitorDeviceMotion"), animated: true)
        }
    }
    
    func routeAlert(){
        var routeName = String()
        let routePrompt = UIAlertController(title: "Enter Route Name", message: "Enter Route", preferredStyle: .Alert)
        routePrompt.inputViewController
        var routeTextField: UITextField?
        routePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            routeTextField = textField
            textField.placeholder = "Route"
        }
        
        routePrompt.addAction(UIAlertAction(title: "Ok",style: .Default,
            handler: { (action) -> Void in
                if let textField = routeTextField {
                    routeName = textField.text as String
                    self.subjectAlert(routeName)
                }
        }))
        self.presentViewController(routePrompt,
            animated: true,
            completion: nil)
    }
    
    func subjectAlert(routeName: String) {
        var subjectName = String()
        
        let subjectPrompt = UIAlertController(title: "Enter Subject Name", message: "Enter Subject", preferredStyle: .Alert)
        subjectPrompt.inputViewController
        var subjectTextField: UITextField?
        subjectPrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            subjectTextField = textField
            textField.placeholder = "Subject"
        }
        
        subjectPrompt.addAction(UIAlertAction(title: "Ok",style: .Default,
            handler: { (action) -> Void in
                if let textField = subjectTextField {
                    subjectName = textField.text
                    let routePredicate = NSPredicate(format: "route.name == %@", routeName)
                    let subjectPredicate = NSPredicate(format: "name == %@", subjectName)
                    let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [routePredicate, subjectPredicate])
                    
                    let fetchRequest = NSFetchRequest(entityName: "Subject")
                    fetchRequest.predicate = predicate
                    if let fetchResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Subject] {
                        print("Predicate worked!")
                        sharedMotion.drive.subject = fetchResults[0]
                        print(sharedMotion.drive.subject)
                        print(sharedMotion.drive)
                    }
                }
        }))
        
        self.presentViewController(subjectPrompt,
            animated: true,
            completion: nil)
    }
    
    @IBAction func modeType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sharedMotion.mode = .Store
        case 1:
            sharedMotion.mode = .Match
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