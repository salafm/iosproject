//
//  Maps.swift
//  Semargres
//
//  Created by NGI-1 on 3/27/18.
//  Copyright © 2018 PT Nusantara Global Inovasi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class  Maps: UIViewController {
    
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation!
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!
    var nama: String!
    var alamat: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nama
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isTranslucent = false
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            openalert()
        }else {
            currentLocation = locationManager.location
            print("\(currentLocation.coordinate.latitude)", "\(currentLocation.coordinate.longitude)")
            loadMap()
        }
    }
    
    func loadMap() {
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 16)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        
        let marker = GMSMarker()
        marker.position = camera.target
        marker.title = nama
        marker.snippet = alamat
        marker.appearAnimation = GMSMarkerAnimation.pop
        marker.map = mapView
        
        let markers = GMSMarker()
        markers.position = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        markers.title = "Anda disini"
        markers.icon = GMSMarker.markerImage(with: .blue)
        markers.appearAnimation = GMSMarkerAnimation.pop
        markers.map = mapView
        
        view = mapView
    }
    
    func openalert(){
        let alert = UIAlertController(title: "Location Service Denied", message: "To re-enable, please go to Settings and turn on Location Service for this app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Pengaturan", style: .default, handler: { _ -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
