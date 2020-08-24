//
//  ForgotPasswordViewController+UI.swift
//  Chat
//
//  Created by  mac on 1/30/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import ProgressHUD
import JGProgressHUD

extension ForgotPasswordViewController{
    
    func validateFields() -> Bool{
        guard let email = emailTextField.text, !email.isEmpty else{
            ProgressHUD.showError(ERROR_EMPTY_EMAIL)
            
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = ERROR_EMPTY_EMAIL
            hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
            
            return false
        }
        return true
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
    
    func setupResetButton(){
        resetButton.setTitle("RESET MY PASSWORD", for: UIControl.State.normal)
        resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        resetButton.backgroundColor = UIColor.black
        resetButton.layer.cornerRadius = 5
        resetButton.clipsToBounds = true
        resetButton .setTitleColor(.white, for: UIControl.State.normal)
    }
    func resetPassword(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Api.User.resetPassword(email: self.emailTextField.text!, onSuccess: {
            onSuccess()
        }) { (errorMessage) in
            onError(errorMessage)
        }
    }
}

