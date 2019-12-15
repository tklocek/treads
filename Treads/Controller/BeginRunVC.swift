//
//  BeginRunVC.swift
//  Treads
//
//  Created by Tomek Klocek on 2019-12-05.
//  Copyright © 2019 Tomek Klocek. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

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
        if mapView.overlays.count > 0 {
            mapView.removeOverlays(mapView.overlays)
        }
        centerMapOnUserLocation()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        mapView.delegate = self
        previousRunView.isHidden = true
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
    
    
    func setupMapView() {
        if let overlay = addLastRunToMap() {
            if mapView.overlays.count > 0 {
                mapView.removeOverlays(mapView.overlays)
            }
            mapView.addOverlay(overlay)
        }
    }
    
    func centerMapOnUserLocation() {
        //mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        mapView.userTrackingMode = .follow
        let coordinateRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnPreviousRoute(locations: List<Location>) -> MKCoordinateRegion {
        guard let initialLoc = locations.first else { return MKCoordinateRegion() }
        var minLat = initialLoc.latitude
        var minLng = initialLoc.longitude
        var maxLat = minLat
        var maxLng = minLng

        for location in locations {
            minLat = min(minLat, location.latitude)
            minLng = min(minLng, location.longitude)
            maxLat = max(maxLat, location.latitude)
            maxLng = max(maxLng, location.longitude)
        }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2), span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.4, longitudeDelta: (maxLng-minLng)*1.4))
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
        
        mapView.userTrackingMode = .none
        mapView.setRegion(centerMapOnPreviousRoute(locations: lastRun.locations), animated: true)
        
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

