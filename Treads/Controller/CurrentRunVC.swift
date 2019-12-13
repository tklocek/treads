//
//  CurrentRunVC.swift
//  Treads
//
//  Created by Tomek Klocek on 2019-12-05.
//  Copyright © 2019 Tomek Klocek. All rights reserved.
//

import UIKit
import MapKit


class CurrentRunVC: LocationVC {

    // Outlets
    @IBOutlet weak var swipeBGImageView: UIImageView!
    @IBOutlet weak var sliderImageView: UIImageView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var paceLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var pauseBtn: UIButton!
    
    // Vars
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var timer = Timer()
    
    var runDistance = 0.0
    var pace = 0
    var counter = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonAnimation()
        
    }
    
    
    func addButtonAnimation() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(endRunSwiped(sender:)))
             sliderImageView.addGestureRecognizer(swipeGesture)
             sliderImageView.isUserInteractionEnabled = true
             swipeGesture.delegate = self as? UIGestureRecognizerDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manager?.delegate = self
        manager?.distanceFilter = 10
        startRun()
        
    }
    
    func startRun() {
        manager?.startUpdatingLocation()
        pauseBtn.setImage(#imageLiteral(resourceName: "pauseButton"), for: .normal)
        startTimer()
    }
    
    func endRun(){
        manager?.stopUpdatingLocation()
        //add our object to Realm
        Run.addRunToRealm(pace: pace, distance: runDistance, duration: counter)
    }
    
    func pauseRun() {
        lastLocation = nil
        startLocation = nil
        timer.invalidate()
        manager?.stopUpdatingLocation()
        pauseBtn.setImage(#imageLiteral(resourceName: "resumeButton"), for: .normal)
    }
    func startTimer() {
        durationLbl.text = counter.formatTimeDurationToString()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounter(){
        counter += 1
        durationLbl.text =  counter.formatTimeDurationToString()
        
    }
    
    func calculatePace(time seconds: Int, kilometers: Double ) -> String {
        pace = Int(Double(seconds) / kilometers.metersToKilometers(places: 2))
        return pace.formatTimeDurationToString()
    }
        
    @IBAction func pauseBtnPressed(_ sender: Any) {
        if timer.isValid {
            pauseRun()
        } else {
            startRun()
        }
    }
    
    @objc func endRunSwiped(sender: UIPanGestureRecognizer) {
        let minAdjust: CGFloat = 83
        let maxAdjust: CGFloat = 128
        
        if let sliderView = sender.view {
            if sender.state == UIGestureRecognizer.State.began || sender.state == UIGestureRecognizer.State.changed {
                let translation = sender.translation(in: self.view)
                
                if sliderView.center.x >= (swipeBGImageView.center.x - minAdjust) && sliderView.center.x <= (swipeBGImageView.center.x + maxAdjust) {
                    sliderView.center.x = sliderView.center.x + translation.x
                } else if sliderView.center.x >= (swipeBGImageView.center.x + maxAdjust) {
                    sliderView.center.x = swipeBGImageView.center.x + maxAdjust
                    endRun()
                    dismiss(animated: true, completion: nil)
                } else {
                    sliderView.center.x = swipeBGImageView.center.x - minAdjust
                }
                sender.setTranslation(CGPoint.zero, in: self.view)
            } else if sender.state == UIGestureRecognizer.State.ended {
                UIView.animate(withDuration: 0.1) {
                    sliderView.center.x = self.swipeBGImageView.center.x - minAdjust
                }
            }
        }
    
    }
    

}


extension CurrentRunVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            checkLocationAuthStatus()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first
            
        } else if let location = locations.last {
            runDistance += lastLocation.distance(from: location)
            distanceLbl.text = "\(runDistance.metersToKilometers(places: 2))"
            if counter > 0 && runDistance > 0 {
                paceLbl.text = calculatePace(time: counter, kilometers: runDistance)
            }
        }
        lastLocation = locations.last
    }
    
}
