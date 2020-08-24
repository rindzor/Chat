//
//  UsersAroundCollectionViewCell.swift
//  Chat
//
//  Created by  mac on 2/16/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class UsersAroundCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var onlineView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var shadowView: UIImageView!
    
    var user: User!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var controller: UsersAroundViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        onlineView.layer.cornerRadius = 25/2
        onlineView.layer.borderWidth = 4
        onlineView.layer.borderColor = UIColor.white.cgColor
        
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 53
        
        shadowView.clipsToBounds = true

        shadowView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]

        shadowView.layer.cornerRadius = 53
        
        onlineView.backgroundColor = .red
        onlineView.clipsToBounds = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let refOnline = Ref().databaseIsOnline(uid: self.user.uid)
        if inboxChangedOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
     
         let refUser = Ref().databaseSpecificUser(uid: self.user.uid)
         if inboxChangedProfileHandle != nil {
             refUser.removeObserver(withHandle: inboxChangedProfileHandle)
         }
    }
    
    func loadData(_ user: User, currentLocation: CLLocation?){
        self.user = user
        if let age = user.age {
            self.ageLabel.text = "\(age)"
        }
        else {
            self.ageLabel.text = ""
        }
        self.avatar.contentMode = .scaleAspectFill
        self.avatar.loadImage(user.profileImageURL)
        self.avatar.loadImage(user.profileImageURL) { (image) in
            user.profileImage = image
        }
        
        //Мониторим онлайн статус в реальном времени в окне чата из БД
        let refOnline = Ref().databaseIsOnline(uid: user.uid)
        refOnline.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any>{
                if let active = snap["online"] as? Bool{
                    self.onlineView.backgroundColor = (active == true) ? .green : .red
                }
            }
        }
        
        if inboxChangedOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        // Мониторим онлайн статус при входе/выходе из приложения без обновления страницы
        inboxChangedOnlineHandle = refOnline.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.onlineView.backgroundColor = (snap as! Bool == true) ? .green : .red
                }
            }
        }
        
        //Обновление пользовательски данных в реальном времени
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.collectionView.reloadData()
            }
        })
        
        guard let _ = currentLocation else {
            return
        }
        
        if !user.longitude.isEmpty && !user.latitue.isEmpty {
            let userLocation = CLLocation(latitude: CLLocationDegrees(Double(user.latitue)!), longitude: CLLocationDegrees(Double(user.longitude)!))
            // Считает расстояние между пользователями в метрах
            let distanceInKm: CLLocationDistance = userLocation.distance(from: currentLocation!) / 1000
            distanceLabel.text = String(format: "%.2f km", distanceInKm)
        } else {
            distanceLabel.text = "No location"
        }
        
        
    }
    
}

