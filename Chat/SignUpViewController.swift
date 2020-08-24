//
//  SignUpViewController.swift
//  Chat
//
//  Created by  mac on 1/29/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD
import CoreLocation
import GeoFire

class SignUpViewController: UIViewController {

    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullNameContainerView: UIView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var image: UIImage? = nil
    let manager = CLLocationManager()
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        setupUI()
    }
    
    
    
    func setupUI(){
        
        // Предварительная настройка интерфейса
        
        setupTitleLabel()
        setupAvatar()
        setupFullNameTextField()
        setupEmailTextField()
        setuppasswordTextField()
        setuoSignUpButton()
        setupSignInButton()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func dismissAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        //Убираем клавиатуру
        self.view.endEditing(true)
        
        // Проверяем заполнены ли все поля
        if validateFields() {
            
            if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String,
                let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
                self.userLat = userLat
                self.userLong = userLong
            }
            
            signUp(onSuccess: {
                // Вносим в БД данные о геопозиции
                if !self.userLat.isEmpty && !self.userLong.isEmpty{
                    let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(self.userLat)!), longitude: CLLocationDegrees(Double(self.userLong)!))
                    
                    // посылаем данные в БД
                    self.geoFireRef = Ref().databaseGeo
                    self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
                    self.geoFire.setLocation(location, forKey: Api.User.currentUserId)
                    
                }
                //Говорим, что юзер в онлайне
                Api.User.isOnline(bool: true)
                 //Переключение между ViewController'ами
                let scene = UIApplication.shared.connectedScenes.first
                if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    sd.configureInitialViewController()
                }
                
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage)
                print(errorMessage)
            }
        }
    }
}
