//
//  Loader.swift
//  Semargres
//
//  Created by NGI-1 on 3/23/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit

public class Loader{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: Loader {
        struct Static {
            static let instance: Loader = Loader()
        }
        return Static.instance
    }
    
    public func startLoader() {
        if  let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let window = appDelegate.window {
            overlayView.frame = UIScreen.main.bounds
            overlayView.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 0/100, alpha: 0.4)
            
            activityIndicator.frame =  CGRect(x: 0, y: 0, width: 40, height: 40)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .whiteLarge
            activityIndicator.center = overlayView.center
            
            overlayView.addSubview(activityIndicator)
            window.addSubview(overlayView)
            
            activityIndicator.startAnimating()
        }
    }
    
    public func stopLoader() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
