//
//  User.swift
//  Chat
//
//  Created by  mac on 2/2/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import UIKit

class User {
    var uid: String
    var username: String
    var email: String
    var profileImageURL: String
    var profileImage = UIImage()
    var status: String
    var isMale: Bool?
    var age: Int?
    var latitue = ""
    var longitude = ""
    
    init(uid: String, username: String, email: String, profileImageURL: String, status: String){
        self.uid = uid
        self.username = username
        self.email = email
        self.profileImageURL = profileImageURL
        self.status = status
    }
    
    static func transformUser(dict: [String: Any]) -> User? {
        // Из словаря dict защищенным способом получаем нужные поля, названия полей важно, так как должно соответствовать этим именам из БД
        guard let email = dict["email"] as? String,
              let username = dict["username"] as? String,
              let status = dict["status"] as? String,
              let uid = dict["uid"] as? String,
              let profileImageURL = dict["profileImageURL"] as? String else {
                return nil
                
        }
        // Инициализируем юзера
        let user = User(uid: uid, username: username, email: email, profileImageURL: profileImageURL, status: status)
        if let isMale = dict["isMale"] as? Bool {
            user.isMale = isMale
        }
        if let age = dict["age"] as? Int {
            user.age = age
        }
        if let latitude = dict["current_latitude"] {
            user.latitue = latitude as! String
        }
        if let longitude = dict["current_longitude"]{
            user.longitude = longitude as! String
        }
        
        return user
    }
    
    func updateData(key: String, value: String){
        switch key {
        case "username": self.username = value
        case "email": self.email = value
        case "profileImageURL": self.profileImageURL = value
        case "status": self.status = value
        default: break
        }
    }
    
}

extension User: Equatable {
    static func == (u1: User, u2: User) -> Bool {
        return u1.uid == u2.uid
    }
}
