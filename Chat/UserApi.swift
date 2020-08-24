//
//  UserApi.swift
//  Chat
//
//  Created by  mac on 2/1/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import ProgressHUD
import FirebaseStorage
import JGProgressHUD
import GoogleSignIn


class UserApi{
    
    // id конкретного юзера
    var currentUserId: String{
        // тернарная операция
        return (Auth.auth().currentUser != nil) ? Auth.auth().currentUser!.uid : " "
    }
    
    func signIn(view: UIView, email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error ) in
            if error != nil{
                
                ProgressHUD.showError(error!.localizedDescription)

                let hud = JGProgressHUD(style: .light)
                hud.textLabel.text = error!.localizedDescription
                hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                hud.show(in: view)
                hud.dismiss(afterDelay: 1)
                return
            }
            print(authDataResult?.user.uid)
            onSuccess()
        }
    }

    func signUp(view: UIView, withUsername username: String, email: String, password: String, image: UIImage?, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        
        // Аутентификация - создание пользователя
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                
                let hud = JGProgressHUD(style: .light)
                hud.textLabel.text = error!.localizedDescription
                hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                hud.show(in: view)
                hud.dismiss(afterDelay: 1)
                
                print(error!.localizedDescription)
                return
            }
            // Создаем новую переменную, тем самым избавляясь от nil значений
            if let authData = authDataResult{
                // Словарь dict хранит поля пользователя, поля описаны глобально в классе Ref
                var dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,               /// уникальный идентификатор
                    EMAIL: authData.user.email,           /// имейл
                    USERNAME: username,                   /// никнейм
                    PROFILE_IMAGE_URL: "",                /// ссылка на фото, добавляется позже
                    STATUS: "Welcome to Chat"             /// статус
                ] 
                

                
                guard let imageSelected = image else {
                    ProgressHUD.showError(ERROR_EMPTY_PHOTO)
                    return
                }
                
                
                // переводим выбранное изображение из типа UIImage в тип Data со сжатием 0.4
                guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
                    return
                }
            
                
                // Ссылка на юзера (файл юзера) в папке profile
                let storageProfile = Ref().storageSpecificProfile(uid: authData.user.uid)
                
                
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                
                
                StorageService.savePhoto(username: username, uid: authData.user.uid, data: imageData, metadata: metaData, storageProfileRef: storageProfile, dict: dict, onSuccess: {
                    onSuccess()
                }) { (errorMessage) in
                    onError(errorMessage)
                }
            }
        }
    }
    
    func saveUserProfile(dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues(dict) { (error, dataRef) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            else{
                onSuccess()
            }
        }
    }
    
    func logOut(){
        do {
            try Auth.auth().signOut()
            
            if let providerData = Auth.auth().currentUser?.providerData {
                let userInfo = providerData[0]

                switch userInfo.providerID {
                case "com.google":
                    GIDSignIn.sharedInstance()?.signOut()
                default:
                    break
                }
            }
        } catch {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
        
    }
    
    func observeUsers(onSuccess: @escaping(UserCompletion)){
        
        // Получаем информацию об изменении данных из узла users в БД
        Ref().databaseUser.observe(.childAdded) { (dataSnapshot) in
            //print(dataSnapshot.value)
            // Парсим эту информицию в словарь dict
            if let dict = dataSnapshot.value as? Dictionary<String, Any>{
                
                // Создаем юзера методом transformUser()
                if let user = User.transformUser(dict: dict) {
                    
                    // Передаем user обратно в PeopleTableViewController
                    onSuccess(user)
                }
            }
        }
    }
    
    func getUserInfoSingleEvent(uid: String, onSuccess: @escaping(UserCompletion)){
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                
                // Создаем юзера методом transformUser()
                if let user = User.transformUser(dict: dict) {
                    
                    // Передаем user обратно в PeopleTableViewController
                    onSuccess(user)
                }
            }
        }
    }
    
    func getUserInfo(uid: String, onSuccess: @escaping(UserCompletion)){
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observe(.value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                
                // Создаем юзера методом transformUser()
                if let user = User.transformUser(dict: dict) {
                    
                    // Передаем user обратно в PeopleTableViewController
                    onSuccess(user)
                }
            }
        }
    }
    
    func isOnline(bool : Bool){
        if !Api.User.currentUserId.isEmpty{
            let ref = Ref().databaseIsOnline(uid: Api.User.currentUserId)
            let dict: Dictionary<String, Any> = [
                "online": bool as Any,
                "latest": Date().timeIntervalSince1970 as Any
            ]
            ref.updateChildValues(dict)
        }
    }
    
    func typing(from: String, to: String){
        let ref = Ref().databaseIsOnline(uid: from)
        let dict: Dictionary<String, Any> = [
            "typing": to
        ]
        ref.updateChildValues(dict)
        
    }
}

typealias UserCompletion = (User) -> Void
