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

    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var previousRunView: UIView!
    @IBOutlet weak var previousPaceLbl: UILabel!
    @IBOutlet weak var previousDistanceLbl: UILabel!
    @IBOutlet weak var previousDurationLbl: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        checkLocationAuthStatus()
        mapView.delegate = self
    }

    @IBAction func previousViewBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: { self.previousRunView.alpha = 0 }, completion:  {
           (value: Bool) in
               self.previousRunView.isHidden = true
        })
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        manager?.startUpdatingLocation()
        showPreviousRun()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }
    
    @IBAction func locationCenterBtnPressed(_ sender: Any) {
        checkLocationAuthStatus()
        centerMapOnUserLocation()
    }
    
    func centerMapOnUserLocation() {
//        guard let coordinate = locationManager.location.coordinate else { return }
//         let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
//         mapView.setRegion(coordinateRegion, animated: true)
        //mapView.setCenterCoordinate(mapView.userLocation.location.coordinate, animated:true)
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
     }
    
    func showPreviousRun() {
        if let run = Run.getLastRun() {
            previousPaceLbl.text = run.pace.formatTimeDurationToString()
            previousDistanceLbl.text = "\(run.distance.metersToKilometers(places: 2)) km"
            previousDurationLbl.text = run.duration.formatTimeDurationToString()
            previousRunView.isHidden = false
        } else {
            previousRunView.isHidden = true
        }
        
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

