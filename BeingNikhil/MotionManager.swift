//
//  MotionManager.swift
//  BeingNikhil
//
//  Manager to keep track of motion recording and DTW analysis
//
//  Created by David M Sirkin on 5/2/15.
//  Revised by Michael P Tucker on 9/1/15
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData
import CoreMotion

class MotionManager: NSObject {
    
    /// AppDelegate to manage data and processes for the app
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    /// Manager for core data objects
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!

    /// Manager for CMMotions
    let manager = CMMotionManager()

    /// Array of z-axis gyroscope rates
    var rotationRates = [Double]()
    
    /// Double for the latest simple moving average of rotation rates
    var SMA = Double()
    
    /// Latest Dynamic Time Warping value
    var DTW = Double()
    
    /// Previous simple moving average of rotation rates
    var priorSMA = Double()
    
    /// Array of z-axis gyroscope rates for a given turn
    var rotationRatesInTurn = [Double]()
    
    /// Array of z-axis gyroscope rates for the previous turn
    var priorRotationRatesInTurn = [Double](count: 1, repeatedValue: 0)
    
    /// Number of turns in a drive
    var turnCount = 0
    
    /// Turn event to be recorded
    lazy var turn = Turn()
    
    /// Timestamp for beginning of drive
    var startMonitoringDate: NSDate!
    
    /// Record of all devices motions during a drive recording
    var deviceMotions = [CMDeviceMotion]()
    
    /// Drive event to be recorded
    lazy var drive = Drive()

    /// Updates the DTW label in the Main View Controller
    func updateDTW() {
        NSNotificationCenter.defaultCenter().postNotificationName("DTW", object: nil)
    }
    
    /**
        Uses a low pass filter to eliminate sensor noise
    
        :param: x An array of Doubles to be filtered
    
        :returns: An array of Doubles that have been filtered
    */
    func lowPassFilter(x: [Double]) -> [Double] {
        let n = x.count, dt = 0.04, RC = 1 / M_2_PI, alpha = dt / (RC + dt)
        
        var y = [Double](count: n, repeatedValue: 0)
        
        y[0] = x[0]
        for i in 1..<n {
            y[i] = alpha * x[i] + (1 - alpha) * y[i - 1]
        }
        return y
    }
    
    /**
        Updates the simple moving average for the rotational movement around the z-axis
    
        :param: z Data from the z-axis gyroscope (adjusted for reference frame)
    */
    func updateSimpleMovingAverageOfRotationalEnergy(z: Double) {
        let k = 25
        
        rotationRates.append(z)
        
        if rotationRates.count > k {
            rotationRates.removeAtIndex(0)
        }
        if rotationRates.isEmpty {
            SMA = 0
        } else {
            SMA = rotationRates.map({ z in pow(z, 2) }).reduce(0, combine: +) / Double(rotationRates.count)
        }
    }
    
    /**
        Performs dynamic time warping algorithm to two arrays of sensor data
        then updates DTW value
    
        :param: s Array of sensor data for first turn
        :param: t Array of sensor data for second turn
    */
    func dynamicTimeWarping(s: [Double], t: [Double]) {
        var n = s.count, m = t.count
        
        if (n == 0 || m == 0) { return }
        
        var DTW = [[Double]](count: n+1, repeatedValue: [Double](count: m+1, repeatedValue: Double.infinity))
        
        DTW[0][0] = 0
        
        for i in 1...n {
            for j in 1...m {
                let cost = abs(s[i-1] - t[j-1])
                //Euclidean distance function for 2 dimensions of data input
                DTW[i][j] = cost + min(DTW[i-1][j], DTW[i][j-1], DTW[i-1][j-1])
            }
        }
        self.DTW = DTW[n][m]
    }
    
    /**
        Determines when a turn event starts and stops.
        Creates a new turn event when the turn starts.
        Adds data to turn event when turn stops
    
        :param: z Data from the z-axis gyroscope (adjusted for reference frame)
    */
    func detectDeviceRotationEndpoints(z: Double) {
        updateSimpleMovingAverageOfRotationalEnergy(z)
        let tU = 0.1, tL = 0.05
        
        if SMA > tU {
            if priorSMA <= tU {
                turnCount++
                rotationRatesInTurn = rotationRates
                turn = NSEntityDescription.insertNewObjectForEntityForName("Turn", inManagedObjectContext: managedObjectContext) as! Turn
                turn.startLocation = sharedLocation.locations[sharedLocation.locations.endIndex - 1]
                turn.startTime = NSDate()
            } else {
                rotationRatesInTurn.append(z)
            }
        } else if SMA < tL {
            if priorSMA >= tL {
                dynamicTimeWarping(priorRotationRatesInTurn, t: rotationRatesInTurn)
                updateDTW()
                priorRotationRatesInTurn = rotationRatesInTurn
                turn.sensorData = priorRotationRatesInTurn
                turn.turnNumber = turnCount
                turn.dataString = priorRotationRatesInTurn.description
                turn.drive = drive
                turn.endTime = NSDate()
                turn.duration = NSDate().timeIntervalSinceDate(turn.startTime)
                turn.endLocation = sharedLocation.locations[sharedLocation.locations.endIndex - 1]
                appDelegate.saveContext()
            }
        }
        priorSMA = SMA
    }
    
    /**
        Stores drive attributes to drive
    */
    func storeDeviceMotionData(){
        drive.timestamp = startMonitoringDate
        drive.locations = sharedLocation.locations
        drive.duration = NSDate().timeIntervalSinceDate(startMonitoringDate)
        drive.selected = false
    }
    
    /**
        Prints data from latest Drive
    */
    func printDeviceMotionData() {
        let fetchDrive = NSFetchRequest(entityName: "Drive")
        fetchDrive.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        if let fetchedDrives = managedObjectContext.executeFetchRequest(fetchDrive, error: nil) as? [Drive] {
            if let drive = fetchedDrives.last {
                print("date: \(drive.timestamp) duration: \(drive.duration)")
            }
        }
        let fetchMotion = NSFetchRequest(entityName: "Turn")
        fetchMotion.predicate = NSPredicate(format: "drive.timestamp == %@", startMonitoringDate)
        
        if let fetchedMotions = managedObjectContext.executeFetchRequest(fetchMotion, error: nil) as? [Turn] {
            for result in fetchedMotions {
                print(result.turnNumber)
            }
            print("")
        }
    }
    
    /**
        Begins monitoring device motion and creates new Drive object
    */
    func startMonitoringDeviceMotion() {
        drive = NSEntityDescription.insertNewObjectForEntityForName("Drive", inManagedObjectContext: managedObjectContext) as! Drive
        sharedLocation.manager.startUpdatingLocation()
        turnCount = 0
        startMonitoringDate = NSDate()
        
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.04
            
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()) {
                [weak self] (data: CMDeviceMotion!, error: NSError!) in
                
                //TRY WITHOUT REFERENCE FRAME CHANGE
                self!.detectDeviceRotationEndpoints(data.rotationRateInReferenceFrame().z)
                self!.deviceMotions.append(data)
            }
        }
    }
    
    /**
        Stops monitoring device and stores data in Drive Object
    */
    func stopMonitoringDeviceMotion() {
        sharedLocation.manager.stopUpdatingLocation()
        if manager.deviceMotionAvailable {
            manager.stopDeviceMotionUpdates()
        }
        storeDeviceMotionData()
        appDelegate.saveContext()
        printDeviceMotionData()
    }
    
//    func compareDrives() {
//        
//        let fetchMotion = NSFetchRequest(entityName: "Turn")
//        fetchMotion.predicate = NSPredicate(format: "drive.timestamp == %@", startMonitoringDate)
//        if let matchTurns = managedObjectContext.executeFetchRequest(fetchMotion, error: nil) as? [Turn] {
//            for matchTurn in matchTurns {
//                let fetchTurnNumber = NSFetchRequest(entityName: "Turn")
//                let firstPredicate = NSPredicate(format: "turnNumber == %@", matchTurn.turnNumber)
//                let secondPredicate = NSPredicate(format: "drive.timestamp != %@", startMonitoringDate)
//                fetchTurnNumber.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [firstPredicate, secondPredicate])
//                if let templateTurns = managedObjectContext.executeFetchRequest(fetchMotion, error: nil) as? [Turn] {
//                    for templateTurn in templateTurns {
//                        dynamicTimeWarping(matchTurn.sensorData as! [Double], t: templateTurn.sensorData as! [Double])
//                        updateDTW()
//                    }
//                }
//
//            }
//        }
//        print("CompareDrives Ran")
//        
//    }
}

/// MotionManager object to be used in other classes
let sharedMotion = MotionManager()