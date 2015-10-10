//
//  File.swift
//  BeingNikhil
//
//  Created by Michael Tucker on 9/10/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class TestController: UIViewController  {
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var graphView: GraphView!
    
    
    var graphIsShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphView.hidden = true
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        graphView.numNewPoints++
//        if (graphIsShowing) {
//            UIView.transitionFromView(graphView, toView: mapView, duration: 1.0, options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
//        } else {
//            UIView.transitionFromView(mapView, toView: graphView, duration: 1.0, options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
//        }
//        graphIsShowing = !graphIsShowing
    }

    
}