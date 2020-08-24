//
//  MapViewController.swift
//  Chat
//
//  Created by  mac on 2/17/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var users = [User]()
    var currentTransportType = MKDirectionsTransportType.automobile
    var currentRoute: MKRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        addAnnotation()
        segmentControl.isHidden = true
        segmentControl.addTarget(self, action: #selector(showDirection(coordinate:)), for: UIControl.Event.valueChanged)
        // Do any additional setup after loading the view.
    }
    
    @objc func showDirection(coordinate: CLLocationCoordinate2D) {
        switch segmentControl.selectedSegmentIndex {
        case 0: self.currentTransportType = .automobile
        case 1: self.currentTransportType = .walking
        default: break
        }
        segmentControl.isHidden = false
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem.forCurrentLocation()
        let directionPlacemark = MKPlacemark(coordinate: coordinate)
        directionRequest.destination = MKMapItem(placemark: directionPlacemark)
        directionRequest.transportType = currentTransportType
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (routeResponse, error) in
            guard let routeResponse = routeResponse else {
                if let error = error {
                    print("EEEEEERRRRRROOOOOOOORRRRR")
                    print(error.localizedDescription)
                    print("EEEEEERRRRRROOOOOOOORRRRR")
                }
                return
            }
            let route = routeResponse.routes[0]
            self.currentRoute = route
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion.init(rect), animated: true)
        }
    }
    
    func addAnnotation() {
        var nearByAnnotations: [MKAnnotation] = []
        for user in users {
            let location = CLLocation(latitude: (Double(user.latitue)!), longitude: (Double(user.longitude)!))
            
            let annotation = UserAnnotation()
            annotation.title = user.username
            if let age = user.age {
                annotation.subtitle = "age : \(age)"
            }
            if let isMale = user.isMale {
                annotation.isMale = (isMale == true) ? true : false
            }
            annotation.profileImage = user.profileImage
            
//            print("-----------")
//            print(annotation.profileImage)
//            print("-----------")

            annotation.coordinate = location.coordinate
            nearByAnnotations.append(annotation)
        }
        self.mapView.showAnnotations(nearByAnnotations, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let identifier = "MyPin"
        var annotationView: MKAnnotationView?

        //reuse the annotaton if possible

        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(systemName: "person.fill")
        }
         if let deqAno = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
            annotationView = deqAno
            annotationView?.annotation = annotation
        }
        else {
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annoView.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
            annotationView = annoView
        }
        if let annotationView = annotationView, let anno = annotation as? UserAnnotation {
            annotationView.canShowCallout = true

            let image = anno.profileImage
            let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            resizeRenderImageView.layer.cornerRadius = 25
            resizeRenderImageView.clipsToBounds = true
            resizeRenderImageView.contentMode = .scaleAspectFill
            resizeRenderImageView.image = image

            UIGraphicsBeginImageContextWithOptions(resizeRenderImageView.frame.size, false, 0.0)
            resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            annotationView.layer.cornerRadius = 25
            annotationView.layer.borderWidth = 3
            annotationView.layer.borderColor = UIColor.white.cgColor
            annotationView.image = thumbnail
            
            let button = UIButton()
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(UIImage(systemName: "arrow.up.right.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)), for: UIControl.State.normal)
            annotationView.rightCalloutAccessoryView = button
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let coordinate = view.annotation?.coordinate{
            showDirection(coordinate: coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = (currentTransportType == .automobile) ? UIColor.blue : UIColor.orange
        render.lineWidth = 3.0
        
        return render
    }
    
}
