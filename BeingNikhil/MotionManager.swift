//
//  MotionManager.swift
//  BeingNikhil
//
//  Created by David M Sirkin on 5/2/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData
import CoreMotion

class MotionManager: NSObject {
    
    let manager = CMMotionManager()
    var drives = [NSManagedObject]()
    
    override init() {
        super.init()
    }
    
    func updateDTW() {
        NSNotificationCenter.defaultCenter().postNotificationName("DTW", object: nil)
    }
    
    func lowPassFilter(x: [Double]) -> [Double] {
        let n = x.count, dt = 0.04, RC = 1 / M_2_PI, alpha = dt / (RC + dt)
        
        var y = [Double](count: n, repeatedValue: 0)
        
        y[0] = x[0]
        for i in 1..<n {
            y[i] = alpha * x[i] + (1 - alpha) * y[i - 1]
        }
        return y
    }
    
    var rotationRates = [Double]()
    var SMA = Double()
    
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
    
    var DTW = Double()
    
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
    
    var priorSMA = Double()
    var rotationRatesInTurn = [Double]()
    var priorRotationRatesInTurn = [Double](count: 1, repeatedValue: 0)
    var turnCount = 0
    
    func detectDeviceRotationEndpoints(z: Double) {
        updateSimpleMovingAverageOfRotationalEnergy(z)
        let tU = 0.1, tL = 0.05
        
        if SMA > tU {
            if priorSMA <= tU {
                turnCount++
                rotationRatesInTurn = rotationRates
            } else {
                rotationRatesInTurn.append(z)
            }
        } else if SMA < tL {
            if priorSMA >= tL {
                let turn = NSEntityDescription.insertNewObjectForEntityForName("Turn", inManagedObjectContext: managedObjectContext) as! Turn
                dynamicTimeWarping(priorRotationRatesInTurn, t: rotationRatesInTurn)
                priorRotationRatesInTurn = rotationRatesInTurn
                turn.sensorData = priorRotationRatesInTurn
                turn.turnNumber = turnCount
                turn.drive = drive
                drive.turnCount = self.turnCount
                updateDTW()
            }
        }
        priorSMA = SMA
    }
    
    var startMonitoringDate: NSDate!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var deviceMotions = [CMDeviceMotion]()
    
    func storeDeviceMotionData() {
        //let drive = NSEntityDescription.insertNewObjectForEntityForName("Drive", inManagedObjectContext: managedObjectContext) as! Drive
        
        drive.timestamp = startMonitoringDate
        drive.duration = NSDate().timeIntervalSinceDate(startMonitoringDate)
        for deviceMotion in deviceMotions {
            //let motion = NSEntityDescription.insertNewObjectForEntityForName("Motion", inManagedObjectContext: managedObjectContext) as! Motion
            let turn = NSEntityDescription.insertNewObjectForEntityForName("Turn", inManagedObjectContext: managedObjectContext) as! Turn
            turn.sensorData = deviceMotion
            turn.drive = drive
        }
    }
    
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
    
    enum Mode {
        case Store
        case Match
    }
    var mode = Mode.Store
    
    
    lazy var drive = Drive()
    
    func startMonitoringDeviceMotion() {
        drive = NSEntityDescription.insertNewObjectForEntityForName("Drive", inManagedObjectContext: managedObjectContext) as! Drive
        sharedLocation.manager.startUpdatingLocation()
        
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
    
    func stopMonitoringDeviceMotion() {
        sharedLocation.manager.stopUpdatingLocation()
        
        if manager.deviceMotionAvailable {
            manager.stopDeviceMotionUpdates()
        }
        if mode == Mode.Store {
            storeDeviceMotionData()
        } else {
            compareDrives()
        }
        printDeviceMotionData()
    }
    
    func compareDrives() {
        
        let fetchMotion = NSFetchRequest(entityName: "Turn")
        fetchMotion.predicate = NSPredicate(format: "drive.timestamp == %@", startMonitoringDate)
        if let matchTurns = managedObjectContext.executeFetchRequest(fetchMotion, error: nil) as? [Turn] {
            for matchTurn in matchTurns {
                let fetchTurnNumber = NSFetchRequest(entityName: "Turn")
                let firstPredicate = NSPredicate(format: "turnNumber == %@", matchTurn.turnNumber)
                let secondPredicate = NSPredicate(format: "drive.timestamp != %@", startMonitoringDate)
                fetchTurnNumber.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [firstPredicate, secondPredicate])
                if let templateTurns = managedObjectContext.executeFetchRequest(fetchMotion, error: nil) as? [Turn] {
                    for templateTurn in templateTurns {
                        dynamicTimeWarping(matchTurn.sensorData as! [Double], t: templateTurn.sensorData as! [Double])
                        updateDTW()
                    }
                }

            }
        }
        print("CompareDrives Ran")
        
    }
}

let sharedMotion = MotionManager()