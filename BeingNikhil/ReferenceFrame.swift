//
//  ReferenceFrame.swift
//  BeingNikhil
//
//  Extension for CMDevideMotion to use rotation matrixes to readjust reference frame
//
//  Created by David M Sirkin on 5/5/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreMotion

extension CMDeviceMotion {
    
    //SIMPLIFY
    func rotationMatrix() -> [[Double]] {
        let zrm = attitude.rotationMatrix
        var grm = [[Double]]()
        grm.append([zrm.m11, zrm.m12, zrm.m13])
        grm.append([zrm.m21, zrm.m22, zrm.m23])
        grm.append([zrm.m31, zrm.m32, zrm.m33])
        let ua = userAcceleration
        var axVector = ua.x * zrm.m11 + ua.y * zrm.m12 + ua.z * zrm.m13
        axVector /= sqrt(pow(ua.x,2) + pow(ua.y,2) + pow(ua.z,2))
        let theta = acos(axVector)
        print(theta)
        var rm = [[Double]]()
        var uarm = [[Double]]()
        uarm.append([cos(theta), sin(theta), 0])
        uarm.append([-sin(theta), cos(theta), 0])
        uarm.append([0, 0, 1])
        for i in 0...2 {
            var row = [Double]()
            for j in 0...2 {
                var column = [Double]()
                column.append(uarm[0][j])
                column.append(uarm[1][j])
                column.append(uarm[2][j])
                row.append(dotProduct(grm[i], b: column))
            }
            rm.append(row)
        }
        
//        for i in 0...2 {
//            print("\(grm[i][0]), \(grm[i][1]), \(grm[i][2])")
//        }
//        for i in 0...2 {
//            print("\(uarm[i][0]), \(uarm[i][1]), \(uarm[i][2])")
//        }
//        for i in 0...2 {
//            print("\(rm[i][0]), \(rm[i][1]), \(rm[i][2])")
//        }

        return rm
    }
    
    func dotProduct(a:[Double], b:[Double]) -> Double {
        var product = 0.0
        for i in 0...a.count - 1 {
            product += a[i] * b[i]            
        }
        return product
    }
    
    func userAccelerationInReferenceFrame(rm:[[Double]]) -> CMAcceleration {
        var uaInRefFrame = CMAcceleration()
        let ua = userAcceleration
        uaInRefFrame.x = ua.x * rm[1][1] + ua.y * rm[1][2] + ua.z * rm[1][3]
        uaInRefFrame.y = ua.x * rm[2][1] + ua.y * rm[2][2] + ua.z * rm[2][3]
        uaInRefFrame.z = ua.x * rm[3][1] + ua.y * rm[3][2] + ua.z * rm[3][3]
        return uaInRefFrame;
    }
    
    func userRotationInReferenceFrame(rm:[[Double]]) -> CMAcceleration {
        var uaInRefFrame = CMAcceleration()
        let rr = rotationRate
        uaInRefFrame.x = rr.x * rm[1][1] + rr.y * rm[1][2] + rr.z * rm[1][3]
        uaInRefFrame.y = rr.x * rm[2][1] + rr.y * rm[2][2] + rr.z * rm[2][3]
        uaInRefFrame.z = rr.x * rm[3][1] + rr.y * rm[3][2] + rr.z * rm[3][3]
        return uaInRefFrame;
    }



//    func userAccelerationInReferenceFrame() -> CMAcceleration {
//        var uaInRefFrame = CMAcceleration()
//        
//        let ua = userAcceleration, rm = attitude.rotationMatrix
//        
//        uaInRefFrame.x = ua.x * rm.m11 + ua.y * rm.m12 + ua.z * rm.m13
//        uaInRefFrame.y = ua.x * rm.m21 + ua.y * rm.m22 + ua.z * rm.m23
//        uaInRefFrame.z = ua.x * rm.m31 + ua.y * rm.m32 + ua.z * rm.m33
//        
//        return uaInRefFrame;
//    }
    
    func rotationRateInReferenceFrame() -> CMRotationRate {
        var rrInRefFrame = CMRotationRate()

        let rr = rotationRate, rm = attitude.rotationMatrix
        
        rrInRefFrame.x = rr.x * rm.m11 + rr.y * rm.m12 + rr.z * rm.m13
        rrInRefFrame.y = rr.x * rm.m21 + rr.y * rm.m22 + rr.z * rm.m23
        rrInRefFrame.z = rr.x * rm.m31 + rr.y * rm.m32 + rr.z * rm.m33
        
        return rrInRefFrame;
    }
}