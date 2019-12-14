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
        
    }

    @IBAction func previousViewBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: { self.previousRunView.alpha = 0 }, completion:  {
           (value: Bool) in
               self.previousRunView.isHidden = true
        })
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        mapView.delegate = self
        previousRunView.isHidden = false
        manager?.startUpdatingLocation()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager?.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupMapView()
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
    
    func setupMapView() {
        if let overlay = addLastRunToMap() {
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            mapView.addOverlay(overlay)
        }
    }
    
    func addLastRunToMap() -> MKPolyline? {
        guard let lastRun = Run.getAllRuns()?.first else { return nil }
            previousPaceLbl.text = lastRun.pace.formatTimeDurationToString()
            previousDistanceLbl.text = "\(lastRun.distance.metersToKilometers(places: 2)) km"
            previousDurationLbl.text = lastRun.duration.formatTimeDurationToString()
            previousRunView.isHidden = false
         
        var coordinate = [CLLocationCoordinate2D]()
        for location in lastRun.locations {
            coordinate.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        
        return MKPolyline(coordinates: coordinate, count: lastRun.locations.count)
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        renderer.lineWidth = 4
        
        return renderer
    }
}

