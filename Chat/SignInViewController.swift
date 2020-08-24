//
//  SignInViewController.swift
//  Chat
//
//  Created by  mac on 1/30/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import ProgressHUD
import JGProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    func setupUI(){
        setupTitleLabel()
        setupEmailTextField()
        setuppasswordTextField()
        setupSignUpButton()
        setupSignInButton()
    }

    @IBAction func dismissAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func signInButtonPressed(_ sender: Any) {
        //Убираем клавиатуру
        self.view.endEditing(true)
        
        // Проверяем заполнены ли все поля
        if validateFields() {
            signIn(onSuccess: {
                //Говорим, что юзер в онлайне
                Api.User.isOnline(bool: true)
                // Переключение между ViewController'ами
                let scene = UIApplication.shared.connectedScenes.first
                if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    sd.configureInitialViewController()
                }
                
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage)
                
                let hud = JGProgressHUD(style: .light)
                hud.textLabel.text = "An error occured"
                hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 1)
            }
        }
    }
    

}
