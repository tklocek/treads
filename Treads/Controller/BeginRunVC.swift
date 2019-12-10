//
//  BeginRunVC.swift
//  Treads
//
//  Created by Tomek Klocek on 2019-12-05.
//  Copyright © 2019 Tomek Klocek. All rights reserved.
//

import UIKit
import MapKit


class BeginRunVC: LocationVC {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        checkLocationAuthStatus()
        mapView.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        manager?.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }
    
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
    
    
    }
    
}

extension BeginRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
            
        }
    }
}

