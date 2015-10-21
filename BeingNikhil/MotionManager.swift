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
    
    /// Array of the lateral accelerometer rates for a given turn
    var lateralAccelerationInTurn = [Double]()
    
    /// Array of the longitudinal accelerometer rates for a given turn
    var longitudinalAccelerationInTurn = [Double]()
    
    /// Number of turns in a drive
    var turnCount = 0
    
    /// Turn event to be recorded
    lazy var turn = NSManagedObject() as! Turn
    
    /// Timestamp for beginning of drive
    var startMonitoringDate: NSDate!
    
    /// Record of all devices motions during a drive recording
    var deviceMotions = [CMDeviceMotion]()
    
    /// Drive event to be recorded
    lazy var drive = NSManagedObject() as! Drive
    
    /// Rotation Matrix oriented by gravity and a forward vector (assumed to be the first movement)
    var rm = [[Double]]()

    /// Updates the DTW label in the Main View Controller
    func updateDTW() {
        NSNotificationCenter.defaultCenter().postNotificationName("DTW", object: nil)
    }
    
//    THE LOW PASS FILTER IS NO LONGER BEING USED / NEEDED
//    /**
//
//        Uses a low pass filter to eliminate sensor noise
//    
//        - parameter x: An array of Doubles to be filtered
//    
//        - returns: An array of Doubles that have been filtered
//    */
//    func lowPassFilter(x: [Double]) -> [Double] {
//        let n = x.count, dt = 0.04, RC = 1 / M_2_PI, alpha = dt / (RC + dt)
//        
//        var y = [Double](count: n, repeatedValue: 0)
//        
//        y[0] = x[0]
//        for i in 1..<n {
//            y[i] = alpha * x[i] + (1 - alpha) * y[i - 1]
//        }
//        return y
//    }
//    
    /**
        Updates the simple moving average for the rotational movement around the z-axis
    
        - parameter z: Data from the z-axis gyroscope (adjusted for reference frame)
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
    
        - parameter s: Array of sensor data for first turn
        - parameter t: Array of sensor data for second turn
    */
    func dynamicTimeWarping(s: [Double], t: [Double]) -> Double {
        let n = s.count, m = t.count
        
        if (n == 0 || m == 0) { return 0}
        
        var DTW = [[Double]](count: n+1, repeatedValue: [Double](count: m+1, repeatedValue: Double.infinity))
        
        DTW[0][0] = 0
        
        for i in 1...n {
            for j in 1...m {
                let cost = abs(pow(s[i-1] - t[j-1],2))
                //Euclidean distance function for 2 dimensions of data input
                DTW[i][j] = cost + min(DTW[i-1][j], DTW[i][j-1], DTW[i-1][j-1])
            }
        }
        self.DTW = DTW[n][m]
        return DTW[n][m]
    }
    
    func multiDimensionalDynamicTimeWarping(s: [CMDeviceMotion], t: [CMDeviceMotion], srm: [[Double]], trm: [[Double]]) {
        
        var sAccelData = [Double]()
        var tAccelData = [Double]()
        var sGyroData = [Double]()
        var tGyroData = [Double]()
        for i in 0...s.count - 1 {
            sAccelData.append(s[i].userAccelerationInReferenceFrame(srm).x)
            sGyroData.append(s[i].userRotationInReferenceFrame(srm).z)
        }
        for i in 0...t.count - 1 {
            tAccelData.append(t[i].userAccelerationInReferenceFrame(trm).x)
            tGyroData.append(t[i].userRotationInReferenceFrame(trm).z)
        }
        
        let accelDTW = dynamicTimeWarping(sAccelData, t: tAccelData)
        let gyroDTW = dynamicTimeWarping(sGyroData, t: tGyroData)
        
        /// FIGURE OUT WHICH COST FUNCTION TO USE!
        let DTW = (exp(-accelDTW) + exp(-gyroDTW)) / 2
        self.DTW = DTW
//        let DTW = sqrt(pow(accelDTW, 2) + pow(gyroDTW, 2))
    }

    
    /**
        Determines when a turn event starts and stops.
        Creates a new turn event when the turn starts.
        Adds data to turn event when turn stops
    
        - parameter z: Data from the z-axis gyroscope (adjusted for reference frame)
    */
    ///UPDATE THIS W/ ACCELERATION
    func detectDeviceRotationEndpoints(motion: CMDeviceMotion) {
        let z = motion.rotationRateInReferenceFrame().z
        updateSimpleMovingAverageOfRotationalEnergy(z)
        let tU = 0.1, tL = 0.05
        
        if SMA > tU {
            if priorSMA <= tU {
                print("new turn")
                turnCount++
                rotationRatesInTurn = rotationRates
                turn = NSEntityDescription.insertNewObjectForEntityForName("Turn", inManagedObjectContext: managedObjectContext) as! Turn
                turn.startLocation = sharedLocation.locations[sharedLocation.locations.endIndex - 1]
                turn.startTime = NSDate()
                deviceMotions = [CMDeviceMotion]()
                deviceMotions.append(motion)
            } else {
                rotationRatesInTurn.append(z)
                deviceMotions.append(motion)
            }
        } else if SMA < tL && priorSMA >= tL{
            dynamicTimeWarping(priorRotationRatesInTurn, t: rotationRatesInTurn)
            updateDTW()
            priorRotationRatesInTurn = rotationRatesInTurn
            turn.sensorData = deviceMotions
            turn.turnNumber = turnCount
            turn.drive = drive
            turn.endTime = NSDate()
            turn.duration = NSDate().timeIntervalSinceDate(turn.startTime)
            turn.endLocation = sharedLocation.locations[sharedLocation.locations.endIndex - 1]
            appDelegate.saveContext()
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
    }
    
    /**
        Prints data from latest Drive
    */
    func printDeviceMotionData() {
        let fetchDrive = NSFetchRequest(entityName: "Drive")
        fetchDrive.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        if let fetchedDrives = (try? managedObjectContext.executeFetchRequest(fetchDrive)) as? [Drive] {
            if let drive = fetchedDrives.last {
                print("date: \(drive.timestamp) duration: \(drive.duration)", terminator: "")
            }
        }
        let fetchMotion = NSFetchRequest(entityName: "Turn")
        fetchMotion.predicate = NSPredicate(format: "drive.timestamp == %@", startMonitoringDate)
        
        if let fetchedMotions = (try? managedObjectContext.executeFetchRequest(fetchMotion)) as? [Turn] {
            for result in fetchedMotions {
                print(result.turnNumber, terminator: "")
            }
            print("", terminator: "")
        }
    }
    
    func accelMagnitude(motion: CMDeviceMotion) -> Double {
        return sqrt(pow(motion.userAcceleration.x,2) + pow(motion.userAcceleration.y,2) + pow(motion.userAcceleration.z,2))
    }
    
    
    func calibrateOrientation(motion: CMDeviceMotion) -> Bool {
        let magnitudeThreshold = 0.5 //FIX THIS THRESHOLD
        if (accelMagnitude(motion) >= magnitudeThreshold) {
            rm = motion.rotationMatrix()
            return true
        }
        return false
    }
    
    
    /**
        Begins monitoring device motion and creates new Drive object
    */
    func startMonitoringDeviceMotion() {
        sharedLocation.manager.startUpdatingLocation()
        drive = NSEntityDescription.insertNewObjectForEntityForName("Drive", inManagedObjectContext: managedObjectContext) as! Drive
        turnCount = 0
        startMonitoringDate = NSDate()
        
        var isOreinted = false
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.04
            
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion?, error: NSError?) in
                
                /// ADD POPUP SCREEN TO TELL USER TO DRIVE FORWARD TO CALIBRATE
                if !isOreinted {
                    self!.updateSimpleMovingAverageOfRotationalEnergy((data?.rotationRateInReferenceFrame().z)!)
                    if self!.calibrateOrientation(data!) {
                        isOreinted = true
                    }
                } else {
                    //TRY WITHOUT REFERENCE FRAME CHANGE
                    print("else ran")
                    self!.detectDeviceRotationEndpoints(data!)
                    //self!.deviceMotions.append(data!)
                    //data?.userAcceleration.x
                }
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
    
    func compareDriveToTemplate(drive: Drive, template: Template) -> [[Double]] {
        var turnScores = [[Double]]()
        var templateTimestamps = [String]()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd h:mm a"

        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let templateDrives = template.drives.sortedArrayUsingDescriptors([sortDescriptor])

        for _ in 1...templateDrives.count {
            turnScores.append(Array(count: drive.turns.count, repeatedValue:Double()))
        }
        
        var driveCounter = 0
        for templateDrive in templateDrives {
            let tempDrive = templateDrive as! Drive
            templateTimestamps.append(dateFormatter.stringFromDate(tempDrive.timestamp))
            for turn in drive.turns {
                let comparisonTurn = turn as! Turn
                for tempTurn in tempDrive.turns {
                    let templateTurn = tempTurn as! Turn
                    if comparisonTurn.turnNumber == templateTurn.turnNumber {
                        multiDimensionalDynamicTimeWarping(comparisonTurn.sensorData, t: templateTurn.sensorData, srm: drive.rm as! [[Double]], trm: templateDrive.rm)
                        turnScores[driveCounter][Int(comparisonTurn.turnNumber) - 1] = DTW
                    }
                }
            }
            driveCounter++
        }
        
        return turnScores
    }
    
    
}

/// MotionManager object to be used in other classes
let sharedMotion = MotionManager()