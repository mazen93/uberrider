//
//  RiderVC.swift
//  uberrider
//
//  Created by mac on 8/5/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController ,CLLocationManagerDelegate,MKMapViewDelegate,UberController{
    
   // test
    
    
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.MyMap.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.MyMap.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.MyMap.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
   
    
   
    @IBOutlet weak var callUberBtn: UIButton!
    
    @IBOutlet weak var MyMap: MKMapView!
    private var locationManager=CLLocationManager()
    private var userLocation:CLLocationCoordinate2D?
    
    // update driver location
    private var driverLocation:CLLocationCoordinate2D?
    private var timer=Timer()
    
    
    
    private var canCallUber=true
    private var riderCanceledUber=false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initializationLocationManager()
        UberHandler.Instance.delegate=self
        UberHandler.Instance.observeMessageForRider()
    }
    
    
    
    // get location
    private func initializationLocationManager(){
        locationManager.delegate=self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if have coordate
        if let location = locationManager.location?.coordinate{
            userLocation=CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region=MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            
            MyMap.setRegion(region, animated: true)
            
            let allAnnotations = self.MyMap.annotations
            self.MyMap.removeAnnotations(allAnnotations)
            
            
            //update driver location
            if driverLocation != nil{
                if !canCallUber{
                    let driverAnnotation=MKPointAnnotation()
                    driverAnnotation.coordinate=driverLocation!
                    driverAnnotation.title="Driver"
                    MyMap.addAnnotation(driverAnnotation)
                    
                    
               
                }
            }
            
            
            let annotation=MKPointAnnotation()
            annotation.coordinate=userLocation!
            annotation.title="Rider"
            MyMap.addAnnotation(annotation)
            
            
            if driverLocation != nil{
                if !canCallUber{
               showRouteOnMap(pickupCoordinate: userLocation!, destinationCoordinate: driverLocation!)
                    print(driverLocation!)
                }
                
            }
            
        }
    }
    
    
    
    
    
    // update driver location
    func updateDriversLocation(lat: Double, lng: Double) {
        driverLocation=CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    @objc func updateRiderLocation()  {
        UberHandler.Instance.updateRiderLocation(lat: (userLocation?.latitude)!, long: (userLocation?.longitude)!)
    }
    
    
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled {
            callUberBtn.setTitle("Cancel Uber", for: UIControlState.normal)
            canCallUber=false
        }else{
            callUberBtn.setTitle("Call Uber", for: UIControlState.normal)
            canCallUber=true
        }
        
    }
    

    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        if !riderCanceledUber {
            if requestAccepted{
                alert(title: "uber Accepted", message: "\(driverName) Accepted Your Uber Request")
            }else{
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                alert(title: "uber Canceld", message: "\(driverName) Canceld your Uber Request")

            }
        }
        riderCanceledUber=false
    }
    
    
    
    
    
    
    
    @IBAction func CallUberButton(_ sender: Any) {
        
        
        // user location not equal nil
        if userLocation != nil {
            
            // if can call uber else in ride
            if canCallUber {
                
                
                
                    UberHandler.Instance.requestUber(latitude: userLocation!.latitude, longitude: userLocation!.longitude)
                
                // update location
                timer=Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(RiderVC.updateRiderLocation), userInfo: nil, repeats: true)
            
            
            }
            
            
            
            else{
                riderCanceledUber=true
                
                // cancel order
                // must get key
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                
                
            }

        }
        
        
    
    }
    
    
    

    @IBAction func logoutButton(_ sender: Any) {
        
        if AuthProvider.Instance.logOut(){
            
            
            
            
            if !canCallUber{
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        }else{
            // could not log out
            self.alert(title: "could not logout", message: "please try again ")
        }
    }
    private func alert(title:String,message:String){
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok=UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    

}
