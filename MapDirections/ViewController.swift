//
//  ViewController.swift
//  MapDirections
//
//  Created by Rupika Sompalli on 15/02/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapV : MKMapView!
    @IBOutlet weak var goBtn : UIButton!
    @IBOutlet weak var msgLabel : UILabel!
    
    var route : MKRoute?
    var count1 = 0
    var count2 = 0
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        msgLabel.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        
        let pickup = CLLocationCoordinate2D(latitude: 43.7538765, longitude: -79.7434302)
        let dest = CLLocationCoordinate2D(latitude: 43.7330325, longitude: -79.770277)
        showRouteOnMap(pickupCoordinate: pickup, destinationCoordinate: dest)
    }

    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MyAnnotation(coordinate: sourcePlacemark.location!.coordinate)
        sourceAnnotation.title = "flag"
        
        let runner1 = MyAnnotation(coordinate: sourcePlacemark.location!.coordinate)
        runner1.title = "runner1"
        let runner2 = MyAnnotation(coordinate: sourcePlacemark.location!.coordinate)
        runner2.title = "runner2"
        
//        if let location = sourcePlacemark.location {
//            sourceAnnotation.coordinate = location.coordinate
//        }
        
        let destinationAnnotation = MyAnnotation(coordinate: destinationPlacemark.location!.coordinate)
        destinationAnnotation.title = "flag"
        
        
        
//        if let location = destinationPlacemark.location {
//            destinationAnnotation.coordinate = location.coordinate
//        }
        
        self.mapV.showAnnotations([sourceAnnotation,runner1,runner2,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
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
            
             self.route = response.routes[0]
            
            
            self.mapV.addOverlay((self.route!.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = self.route!.polyline.boundingMapRect
            self.mapV.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
             if annotation.title == "flag"{
              annotationView.image = UIImage(named: "icons8-flag-filled-96")
            }else if annotation.title == "runner1"{
                annotationView.image = UIImage(named: "icons8-cyclist-96")
            }else if annotation.title == "runner2"{
                annotationView.image = UIImage(named: "icons8-cycling-96")
            }
            
        }
        
        return annotationView
    }
    
    
    @IBAction func goClicked(){
        
        
        var coords: [CLLocationCoordinate2D] = []
       // coords.reserveCapacity(self.route!.polyline.pointCount)
        
        var coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: self.route!.polyline.pointCount)
        self.route?.polyline.getCoordinates(coordsPointer, range: NSRange(location: 0, length: self.route!.polyline.pointCount))
        
        for i in 0..<self.route!.polyline.pointCount {
            coords.append(coordsPointer[i])
        }
        
        print(coords)
        
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(ViewController.updatingRunner1(timer:)), userInfo: coords, repeats: true)
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(ViewController.updatingRunner2(timer:)), userInfo: coords, repeats: true)
        
//        let source = mapV.annotations[0] as? MyAnnotation
//
//        DispatchQueue.global(qos: .background).async {// global() will use a background thread rather than the main thread
//            for coordinate in coords{
//                DispatchQueue.main.sync {
//                    UIView.animate(withDuration: 0.5) {
//                        source!.coordinate = coordinate
//                    }
//                }
////                sleep(1)
//            }
//
//        }
        
        
    }
    
    @objc func updatingRunner1(timer:Timer) {
        
        if count1 >= self.route!.polyline.pointCount - 1{
            timer.invalidate()
            self.timer = nil
            msgLabel.isHidden = false
            msgLabel.startBlink()
            return
        }
        
        let coords = timer.userInfo as? [CLLocationCoordinate2D]
        let source = mapV.annotations.filter({
            $0.title == "runner1"}).last as! MyAnnotation
        
        UIView.animate(withDuration: 1.5) {
            source.coordinate = coords![self.count1]
        }
        
        count1 += 1
       
    }
    
    @objc func updatingRunner2(timer:Timer) {
        
        if count2 >= self.route!.polyline.pointCount - 1{
            timer.invalidate() 
            self.timer = nil
            return
        }
        
        let coords = timer.userInfo as? [CLLocationCoordinate2D]
        let source = mapV.annotations.filter({
            $0.title == "runner2"}).last as! MyAnnotation
        
        UIView.animate(withDuration: 1.0) {
            source.coordinate = coords![self.count2]
        }
        
        count2 += 1
        
    }
    
    func moveBall(coordinate:CLLocationCoordinate2D){
        let source = mapV.annotations[0] as? MyAnnotation
        UIView.animate(withDuration: 1.5) {
            source!.coordinate = coordinate
        }
    }

}


extension UILabel {
    
    func startBlink() {
        UIView.animate(withDuration: 0.8,
                       delay:0.0,
                       options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                       animations: { self.alpha = 0 },
                       completion: nil)
    }
    
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}
