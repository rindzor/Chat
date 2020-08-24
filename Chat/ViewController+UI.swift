//
//  ViewController+UI.swift
//  Chat
//
//  Created by  mac on 1/29/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import JGProgressHUD
import FBSDKLoginKit
import Firebase
import GoogleSignIn

extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func setupHeaderTitle(){
           let title = "Create a new account"
           let subTitle = "\n\nLorem ipsum set ame cone tetur adipididns elit set do."
           
           let attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.init(name: "Didot", size: 28)!,
                NSAttributedString.Key.foregroundColor : UIColor.black])
           
           let attributedSubTitle = NSMutableAttributedString(string: subTitle, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.45)])
           
           attributedText.append(attributedSubTitle)
           
           let paragraphStyle = NSMutableParagraphStyle()
           paragraphStyle.lineSpacing = 5
           
           attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
           titleLabel.numberOfLines = 0 // infinite number of lines
           
           titleLabel.attributedText = attributedText
       }
    func setupOrLabel(){
        orLabel.text = "Or"
        orLabel.font = UIFont.boldSystemFont(ofSize: 16)
        orLabel.textColor = UIColor(white: 0, alpha: 0.45)
        orLabel.textAlignment = NSTextAlignment.center
    }
    func setupTermsLabel(){
        let attributedTermsText = NSMutableAttributedString(string: "By clicking 'Create a new account' you agree to our ", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)])
        let attributedSubTermsTitle = NSMutableAttributedString(string: "Terms of Service", attributes: [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.45)])
        
        attributedTermsText.append(attributedSubTermsTitle)
        
        termsOfServiceLabel.attributedText = attributedTermsText
        termsOfServiceLabel.numberOfLines = 0 // infinite number of lines
    }
    func setupFacebookButton(){
        signInFacebookButton.setTitle("Sign in with Facebook", for: UIControl.State.normal)
        signInFacebookButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signInFacebookButton.backgroundColor = UIColor(red: 58/255, green: 85/255, blue: 159/255, alpha: 1)
        signInFacebookButton.layer.cornerRadius = 5
        signInFacebookButton.clipsToBounds = true
        
        signInFacebookButton.setImage(UIImage(named: "facebooklogo"), for: UIControl.State.normal)
        signInFacebookButton.imageView?.contentMode = .scaleAspectFit
        signInFacebookButton.tintColor = .white
        signInFacebookButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 280)
        
        signInFacebookButton.addTarget(self, action: #selector(fbButtonPressed), for: UIControl.Event.touchUpInside)
    }
    
    @objc func fbButtonPressed() {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                
                let hud = JGProgressHUD(style: .light)
                hud.textLabel.text = error.localizedDescription
                hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 1.0)
                return
            }
            
            guard let accessToken = AccessToken.current else {
                let hud = JGProgressHUD(style: .light)
                hud.textLabel.text = "Failed to get access token"
                hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 1.0)
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error {
                    
                    let hud = JGProgressHUD(style: .light)
                    hud.textLabel.text = error.localizedDescription
                    hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    hud.show(in: self.view)
                    hud.dismiss(afterDelay: 1.0)
                    return
                }
                if let authData = result {
                    print("authData", authData.user.email)
                    
                    var dict: Dictionary<String, Any> = [
                        UID: authData.user.uid,               /// уникальный идентификатор
                        EMAIL: authData.user.email,           /// имейл
                        USERNAME: authData.user.displayName,  /// никнейм
                        PROFILE_IMAGE_URL: authData.user.photoURL?.absoluteString,  /// ссылка на фото, добавляется позже
                        STATUS: "Welcome to Chat"             /// статус
                    ]
                    
                    Ref().databaseSpecificUser(uid: authData.user.uid).updateChildValues(dict) { (error, databaseReference) in
                        if error == nil{
                            Api.User.isOnline(bool: true)
                            let scene = UIApplication.shared.connectedScenes.first
                            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                                sd.configureInitialViewController()
                            }
                        }
                        else{
                         let hud = JGProgressHUD(style: .light)
                         hud.textLabel.text = error!.localizedDescription
                         hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                         hud.show(in: self.view)
                         hud.dismiss(afterDelay: 1.0)
                        }
                    }
                }
            }
        }
    }
    
    func setupGoogleButton(){
        signInGoogleButton.setTitle("Sign in with Google", for: UIControl.State.normal)
        signInGoogleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signInGoogleButton.backgroundColor = UIColor(red: 223/255, green: 74/255, blue: 50/255, alpha: 1)
        signInGoogleButton.layer.cornerRadius = 5
        signInGoogleButton.clipsToBounds = true
        
        signInGoogleButton.setImage(UIImage(named: "googlelogo"), for: UIControl.State.normal)
        signInGoogleButton.imageView?.contentMode = .scaleAspectFit
        signInGoogleButton.tintColor = .white
        signInGoogleButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 280)
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
        signInGoogleButton.addTarget(self, action: #selector(googleButtonPressed), for: UIControl.Event.touchUpInside)
    }

    
    @objc func googleButtonPressed() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            if let error = error {
                
                let hud = JGProgressHUD(style: .light)
                hud.textLabel.text = error.localizedDescription
                hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 1.0)
                return
            }
            if let authData = result {
                print("authData", authData.user.email)
                
                var dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,               /// уникальный идентификатор
                    EMAIL: authData.user.email,           /// имейл
                    USERNAME: authData.user.displayName,  /// никнейм
                    PROFILE_IMAGE_URL: (authData.user.photoURL == nil) ? "" : authData.user.photoURL!.absoluteString,  /// ссылка на фото, добавляется позже
                    STATUS: "Welcome to Chat"             /// статус
                ]
                
                Ref().databaseSpecificUser(uid: authData.user.uid).updateChildValues(dict) { (error, databaseReference) in
                    if error == nil{
                        Api.User.isOnline(bool: true)
                        let scene = UIApplication.shared.connectedScenes.first
                        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                            sd.configureInitialViewController()
                        }
                    }
                    else{
                     let hud = JGProgressHUD(style: .light)
                     hud.textLabel.text = error!.localizedDescription
                     hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                     hud.show(in: self.view)
                     hud.dismiss(afterDelay: 1.0)
                    }
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = error!.localizedDescription
        hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.0)
    }
    
    func setupCreateAccountButton(){
        createAccountButton.setTitle("Create a new account", for: UIControl.State.normal)
       createAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
       createAccountButton.backgroundColor = UIColor.black
       createAccountButton.layer.cornerRadius = 5
       createAccountButton.clipsToBounds = true
    }
}
