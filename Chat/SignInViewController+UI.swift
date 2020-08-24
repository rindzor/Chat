//
//  SignInViewController+UI.swift
//  Chat
//
//  Created by  mac on 1/30/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import ProgressHUD
import JGProgressHUD

extension SignInViewController{
    func setupTitleLabel(){
         let title = "Sign In "
         
         
         let attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.init(name: "Didot", size: 28)!,
              NSAttributedString.Key.foregroundColor : UIColor.black])
         
    
         titleTextLabel.numberOfLines = 0 // infinite number of lines
         
         titleTextLabel.attributedText = attributedText
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
     func setupSignInButton(){
         signInButton.setTitle("Sign In ", for: UIControl.State.normal)
         signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
         signInButton.backgroundColor = UIColor.black
         signInButton.layer.cornerRadius = 5
         signInButton.clipsToBounds = true
         signInButton .setTitleColor(.white, for: UIControl.State.normal)
     }
     func setupSignUpButton(){
         let attributedText = NSMutableAttributedString(string: "Don't have an account? ", attributes: [
             NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
             NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)])
        
         let attributedSubTitle = NSMutableAttributedString(string: "Sign Up ", attributes: [
             NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor : UIColor.black])
         
         attributedText.append(attributedSubTitle)
         
         signUpButton.setAttributedTitle(attributedText, for: UIControl.State.normal)
         
     }
    
    func validateFields() -> Bool{

        guard let email = emailTextField.text, !email.isEmpty else{
            ProgressHUD.showError(ERROR_EMPTY_EMAIL)
            print(ERROR_EMPTY_EMAIL)
            
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = ERROR_EMPTY_EMAIL
            hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
            
            return false
        }
        guard let password = passwordTextField.text, !password.isEmpty else{
            ProgressHUD.showError(ERROR_EMPTY_PASSWORD)
            print(ERROR_EMPTY_PASSWORD)
            
            let hud = JGProgressHUD(style: .light)
           hud.textLabel.text = ERROR_EMPTY_PASSWORD
           hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
           hud.show(in: self.view)
           hud.dismiss(afterDelay: 1.0)
            
            return false
        }

        return true
    }
    
    func signIn(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
          
          // Во время выполнения функции крутится ползунок
          let hud = JGProgressHUD(style: .light)
          hud.textLabel.text = "Loading..."
          hud.show(in: self.view)
          hud.dismiss(afterDelay: 1.0) 
        
        Api.User.signIn(view: self.view, email: self.emailTextField.text!, password: self.passwordTextField.text!, onSuccess: {
            onSuccess()
            //ProgressHUD.dismiss()
        }) { (errorMessage) in
            onError(errorMessage)
        }
      }
}
