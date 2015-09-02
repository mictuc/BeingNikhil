//
//  ReferenceFrame.swift
//  BeingNikhil
//
//  Extension for CMDevideMotino to use rotation matrixes to readjust reference frame
//
//  Created by David M Sirkin on 5/5/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import CoreMotion

extension CMDeviceMotion {

    func userAccelerationInReferenceFrame() -> CMAcceleration {
        var uaInRefFrame = CMAcceleration()
        
        let ua = userAcceleration, rm = attitude.rotationMatrix
        
        uaInRefFrame.x = ua.x * rm.m11 + ua.y * rm.m12 + ua.z * rm.m13
        uaInRefFrame.y = ua.x * rm.m21 + ua.y * rm.m22 + ua.z * rm.m23
        uaInRefFrame.z = ua.x * rm.m31 + ua.y * rm.m32 + ua.z * rm.m33
        
        return uaInRefFrame;
    }
    
    func rotationRateInReferenceFrame() -> CMRotationRate {
        var rrInRefFrame = CMRotationRate()

        let rr = rotationRate, rm = attitude.rotationMatrix
        
        rrInRefFrame.x = rr.x * rm.m11 + rr.y * rm.m12 + rr.z * rm.m13
        rrInRefFrame.y = rr.x * rm.m21 + rr.y * rm.m22 + rr.z * rm.m23
        rrInRefFrame.z = rr.x * rm.m31 + rr.y * rm.m32 + rr.z * rm.m33
        
        return rrInRefFrame;
    }
}