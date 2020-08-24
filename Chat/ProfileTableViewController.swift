//
//  ProfileTableViewController.swift
//  Chat
//
//  Created by  mac on 2/11/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import JGProgressHUD


class ProfileTableViewController: UITableViewController {

    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var statusLabel: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        observeData()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//           // Убираем клавиатуру по нажатию на пустом месте
//           view.endEditing(true)
//    }
    
    func observeData(){
        Api.User.getUserInfoSingleEvent(uid: Api.User.currentUserId) { (user) in
            self.usernameLabel.text = user.username
            self.emailLabel.text = user.email
            self.statusLabel.text = user.status
            self.avatar.loadImage(user.profileImageURL)
            
            if let age = user.age {
                self.ageTextField.text = "\(age)"
            }
            else {
                self.ageTextField.placeholder = "Optional"
            }
            
            if let isMale = user.isMale {
                self.genderSegment.selectedSegmentIndex = (isMale == true) ? 0 : 1
            }
        }
    }
    
    func setupView(){
        setupAvatar()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard)))
    }
    
    @objc func dissmissKeyboard(){
        view.endEditing(true)
    }
    
    func setupAvatar(){
        self.avatar.layer.cornerRadius = 40
        self.avatar.clipsToBounds = true
        self.avatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        self.avatar.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentPicker(){
        view.endEditing(true)
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil )
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        Api.User.isOnline(bool: false)
        Api.User.logOut()
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sd.configureInitialViewController()
        }
    }
    
    @IBAction func backgroundButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let backgroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_BACKGROUND) as! BackgroundCollectionViewController
        
        // Перебрасываем пользователя на ChatViewController
        self.navigationController?.pushViewController(backgroundVC, animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let hud = JGProgressHUD(style: .light)
         hud.textLabel.text = "Loading..."
         hud.show(in: self.view)
         hud.dismiss(afterDelay: 1.0)
        
        
        var dict = Dictionary<String, Any>()
        if let username = usernameLabel.text, !username.isEmpty {
            dict["username"] = username
        }
        if let email = emailLabel.text, !email.isEmpty {
            dict["email"] = email
        }
        if let status = statusLabel.text, !status.isEmpty {
            dict["status"] = status
        }
        if genderSegment.selectedSegmentIndex == 0{
            dict["isMale"] = true
        }
        if genderSegment.selectedSegmentIndex == 1{
            dict["isMale"] = false
        }
        if let age = ageTextField.text, !age.isEmpty {
            dict["age"] = Int(age)
        }
        
        Api.User.saveUserProfile(dict: dict, onSuccess: {
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = "Info changed!"
            hud.indicatorView = JGProgressHUDSuccessIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
            if let img = self.image{
                StorageService.saveNewPhoto(image: img, uid: Api.User.currentUserId, onSuccess: {
   
                }) { (errorMessage) in
                    let hud = JGProgressHUD(style: .light)
                    hud.textLabel.text = errorMessage
                    hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    hud.show(in: self.view)
                    hud.dismiss(afterDelay: 1.0)
                }
            }
        }) { (errorMessage) in
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = errorMessage
            hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
        }
    }
    
}

extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageEditedSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            
            avatar.image = imageEditedSelected
            image = imageEditedSelected
        }
        if let imageOriginalSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            avatar.image = imageOriginalSelected
            image = imageOriginalSelected
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}

    
