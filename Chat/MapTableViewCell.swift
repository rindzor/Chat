//
//  MapTableViewCell.swift
//  Chat
//
//  Created by  mac on 2/19/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapIcon: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    var controller: DetailViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapIcon.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapIcon.addGestureRecognizer(tapGesture)
    }
    
    @objc func showMap() {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_MAP) as! MapViewController
        mapVC.users = [controller.user]
        // Перебрасываем пользователя на ChatViewController
        controller.navigationController?.pushViewController(mapVC, animated: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        self.mapView.setRegion(region, animated: true)
    }

}
