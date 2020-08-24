//
//  SignUpViewController+UI.swift
//  Chat
//
//  Created by  mac on 1/30/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import ProgressHUD
import JGProgressHUD
import CoreLocation

extension SignUpViewController{
    
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
    }
    
    func validateFields() -> Bool{
        guard let username = fullNameTextField.text, !username.isEmpty else{
            print(ERROR_EMPTY_USERNAME)
            ProgressHUD.showError(ERROR_EMPTY_USERNAME)
            
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = ERROR_EMPTY_USERNAME
            hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
            
            return false
        }
        guard let email = emailTextField.text, !email.isEmpty else{
            print(ERROR_EMPTY_EMAIL)
            ProgressHUD.showError(ERROR_EMPTY_EMAIL)
            
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = ERROR_EMPTY_EMAIL
            hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
            
            return false
        }
        guard let password = passwordTextField.text, !password.isEmpty else{
            print(ERROR_EMPTY_PASSWORD)
            ProgressHUD.showError(ERROR_EMPTY_PASSWORD)
            
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = ERROR_EMPTY_PASSWORD
            hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
            
            return false
        }
        if self.image == nil{
            print(ERROR_EMPTY_PHOTO)
            ProgressHUD.showError(ERROR_EMPTY_PHOTO)
            
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = ERROR_EMPTY_PHOTO
            hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1)
            
            return false
        }
        return true
    }
    
    func setupTitleLabel(){
        let title = "Sign Up"
        
        
        let attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.init(name: "Didot", size: 28)!,
             NSAttributedString.Key.foregroundColor : UIColor.black])
        
   
        titleTextLabel.numberOfLines = 0 // infinite number of lines
        
        titleTextLabel.attributedText = attributedText
    }
    
    func setupAvatar(){
        avatar.layer.cornerRadius = 40
        avatar.clipsToBounds = true
        avatar.isUserInteractionEnabled = true
        avatar.contentMode = .scaleAspectFill
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatar.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentPicker(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil )
    }
    
    func setupFullNameTextField(){
        fullNameContainerView.layer.borderWidth = 1
        fullNameContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        
        fullNameContainerView.layer.cornerRadius = 3
        fullNameContainerView.clipsToBounds = true
        
        fullNameTextField.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Full Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        fullNameTextField.attributedPlaceholder = placeholderAttr
        fullNameTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    func setupEmailTextField(){
        emailContainerView.layer.borderWidth = 1
        emailContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        
        emailContainerView.layer.cornerRadius = 3
        emailContainerView.clipsToBounds = true
        
        emailTextField.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        emailTextField.attributedPlaceholder = placeholderAttr
        emailTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    func setuppasswordTextField(){
        passwordContainerView.layer.borderWidth = 1
        passwordContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        
        passwordContainerView.layer.cornerRadius = 3
        passwordContainerView.clipsToBounds = true
        
        passwordTextField.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Password (8+ Characters)", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        passwordTextField.attributedPlaceholder = placeholderAttr
        passwordTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    func setuoSignUpButton(){
        signUpButton.setTitle("Sign Up", for: UIControl.State.normal)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        signUpButton.backgroundColor = UIColor.black
        signUpButton.layer.cornerRadius = 5
        signUpButton.clipsToBounds = true
        signUpButton.setTitleColor(.white, for: UIControl.State.normal)
    }
    func setupSignInButton(){
        let attributedText = NSMutableAttributedString(string: "Already have an account? ", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)])
        let attributedSubTitle = NSMutableAttributedString(string: "Sign In", attributes: [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.black])
        
        attributedText.append(attributedSubTitle)
        
        signInButton.setAttributedTitle(attributedText, for: UIControl.State.normal)
        
    }



    func signUp(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        
        // Во время выполнения функции крутится ползунок
        ProgressHUD.show("Loading...")
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Loading..."
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.0)
        
        Api.User.signUp(view: self.view, withUsername: self.fullNameTextField.text!, email: self.emailTextField.text!, password: self.passwordTextField.text!, image: self.image, onSuccess: {
            ProgressHUD.showSuccess()
            ProgressHUD.dismiss()
            
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = "Signed Up!"
            hud.indicatorView = JGProgressHUDSuccessIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
            
            
            onSuccess()
        }) { (errorMessage) in
            onError(errorMessage)
        }
        
    }
}


//MARK: - UIImagePickerControllerDelegate

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageEditedSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            
            avatar.image = imageEditedSelected
            image = imageEditedSelected // image глобальная переменная из SignUpViewController
        }
        if let imageOriginalSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            avatar.image = imageOriginalSelected
            image = imageOriginalSelected // image глобальная переменная из SignUpViewController
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - CLLocationManagerDelegate

extension SignUpViewController: CLLocationManagerDelegate{
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
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        print(newCoordinate.latitude, newCoordinate.longitude)
        // update location
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.set("\(newCoordinate.latitude)", forKey: "current_location_latitude")
        userDefaults.set("\(newCoordinate.longitude)", forKey: "current_location_longitude")
        userDefaults.synchronize()
        
    }
}
