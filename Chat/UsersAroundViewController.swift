//
//  UsersAroundViewController.swift
//  Chat
//
//  Created by  mac on 2/16/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import CoreLocation
import GeoFire
import FirebaseDatabase
import JGProgressHUD

class UsersAroundViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var mapViewButton: UIButton!
    
    let mySlider = UISlider()
    let distanceLabel = UILabel()
    let manager = CLLocationManager()
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire! // Хранит данные о геолокации в Firebase location
    var geoFireRef: DatabaseReference!
    var myQuery: GFQuery! // Объект обрабатывает geo запросы в Firebase location
    var distance: Double = 50
    var users: [User] = []
    var queryHandle: DatabaseHandle?
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        setupNavigationBar()
    }
    
    func configureLocationManager(){
        // Предпочитаемая точность
        manager.desiredAccuracy = kCLLocationAccuracyBest
        //На какое расстояние должен гоизонтально передвинуться девайс, чтобы произошло обновление локации
        manager.distanceFilter = kCLDistanceFilterNone
        //если true, то обновление прекразается, когда гаджет неподвижен
        manager.pausesLocationUpdatesAutomatically = true
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled(){
            manager.startUpdatingLocation()
        }
        
        self.geoFireRef = Ref().databaseGeo
        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
    }
    
    func setupNavigationBar() {
        title = "Users Around"
        
        let refresh = UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(refreshPressed))
        
        distanceLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        distanceLabel.font = UIFont.systemFont(ofSize: 13)
        distanceLabel.text = "\(Int(distance)) km"
        distanceLabel.textColor = .gray
        let distanceItem = UIBarButtonItem(customView: distanceLabel)
        
        
        mySlider.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        mySlider.minimumValue = 1
        mySlider.maximumValue = 100
        mySlider.value = Float(distance)
        // Значения слайдера будут обновляться сразу за пальцем
        mySlider.isContinuous = true
        mySlider.tintColor = .black
        mySlider.addTarget(self, action: #selector(sliderValueChanged), for: UIControl.Event.valueChanged)
        navigationItem.titleView = mySlider
        navigationItem.rightBarButtonItems = [refresh, distanceItem]
    }
    
    @objc func refreshPressed(){
        findUsers()
    }
    
    @objc func sliderValueChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            
            print(slider.value)
            distance = Double(slider.value)
            distanceLabel.text = "\(Int(slider.value)) km"
            
            switch touchEvent.phase {
            case .began:
                print("began")
            case .moved:
                print("moved")
            case .ended:
                findUsers()
            default:
                break
            }
        }
        
        
    }
    
    func findUsers() {
        
        if queryHandle != nil, myQuery != nil{
            myQuery.removeObserver(withFirebaseHandle: queryHandle!)
            myQuery = nil
            queryHandle = nil
        }
            
        guard let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String,
        let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String else {
            return
        }
        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
        
        self.users.removeAll()
        
        myQuery = geoFire.query(at: location, withRadius: distance)
        
        queryHandle = myQuery.observe(GFEventType.keyEntered, with: { (key, location) in
            // key - user id

            if key != Api.User.currentUserId {
                Api.User.getUserInfoSingleEvent(uid: key) { (user) in
                    if self.users.contains(user) {
                        return
                    }
                    
                    // Чтобы приложение не крашилось, если графа пол незаполнена
                    if user.isMale == nil {
                        return
                    }
                    
                    switch self.segmentControl.selectedSegmentIndex {
                        case 0:
                            if user.isMale!{
                                self.users.append(user)
                                
                        }
                        case 1:
                            if !(user.isMale!) {
                                self.users.append(user)
                                
                        }
                        case 2:
                            self.users.append(user)
                            
                        default:
                            break
                    }
                    self.collectionView.reloadData()
                }
            }
        })

    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        findUsers()
    }
    
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_MAP) as! MapViewController
        mapVC.users = self.users
        // Перебрасываем пользователя на ChatViewController
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    

}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension UsersAroundViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersAroundCollectionViewCell", for: indexPath) as! UsersAroundCollectionViewCell
        let user = users[indexPath.item]
        cell.controller = self
        cell.loadData(user, currentLocation: self.currentLocation)

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width/3 - 2, height: view.frame.height/6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? UsersAroundCollectionViewCell{

            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let detailVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_DETAIL) as! DetailViewController
            detailVC.user = cell.user
        
            // Перебрасываем пользователя на ChatViewController
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    
}

//MARK: - CLLocationManagerDelegate

extension UsersAroundViewController: CLLocationManagerDelegate{
    // Какие настройки конфиденциальности по отношению к своей локации выбрал пользователь
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways ) || (status == .authorizedWhenInUse){
            manager.startUpdatingLocation()
        }
    }
    
    // Выполняется в случае ошибки
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "\(error.localizedDescription)"
        hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.0)
    }
    
    // Сообщает делгату, что доступна новая локация
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Чтобы обновить локацию единожды при вызове этого жкрана
        manager.stopUpdatingLocation()
        manager.delegate = nil
        print("didUpdateLocations")
        
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        self.currentLocation = updatedLocation
        
        //print(newCoordinate.latitude, newCoordinate.longitude)
        // update location
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.set("\(newCoordinate.latitude)", forKey: "current_location_latitude")
        userDefaults.set("\(newCoordinate.longitude)", forKey: "current_location_longitude")
        userDefaults.synchronize()
        
        if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String,
        let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
            Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([LAT: userLat, LONG: userLong])
                
 
                //self.geoFire.setLocation(location, forKey: Api.User.currentUserId)
            self.geoFire.setLocation(location, forKey: Api.User.currentUserId) { (error) in
                if error == nil {
                    self.findUsers()
                }
            }
        }
    }
    
    
    
}
