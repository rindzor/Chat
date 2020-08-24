//
//  Ref.swift
//  Chat
//
//  Created by  mac on 2/1/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import Firebase

let REF_USER = "users"
let REF_MESSAGE = "messages"
let REF_INBOX = "inbox"
let REF_GEO = "Geolocs"

let URL_STORAGE_ROOT = "gs://chat-14df3.appspot.com/"
let STORAGE_PROFILE = "profile"
let PROFILE_IMAGE_URL = "profileImageURL"
let UID = "uid"
let EMAIL = "email"
let USERNAME = "username"
let STATUS = "status"
let LAT = "current_latitude"
let LONG = "current_longitude"

let ERROR_EMPTY_PHOTO = "Please choose your profile image"
let ERROR_EMPTY_EMAIL = "Please enter an email address"
let ERROR_EMPTY_USERNAME = "Please enter an username"
let ERROR_EMPTY_PASSWORD = "Please enter a password"

let SUCCESS_EMAIL_RESET = "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password"

let IDENTIFIER_TABBAR = "TabBarVC"
let IDENTIFIER_WELCOME = "WelcomeVC"
let IDENTIFIER_CHAT = "ChatVC"
let IDENTIFIER_USERS_AROUND = "UsersAroundViewController"
let IDENTIFIER_MAP = "MapViewController"
let IDENTIFIER_DETAIL = "DetailViewController"
let IDENTIFIER_BACKGROUND = "BackgroundCollectionViewController"

let IDENTIFIER_CELL_USERS = "UserTableViewCell"

let DEFAULTS = UserDefaults.standard
var wallpaperName = DEFAULTS.string(forKey: "wallpaperName")


class Ref {
    
    /// ссылка на корневой узел БД в Firebase Database
    let databaseRoot: DatabaseReference = Database.database().reference()
    
    /// узел users в БД в Firebase Database
    var databaseUser: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
    
    /// Возвращает узел конкретного юзера в узле users в БД в Firebase Database
    func databaseSpecificUser(uid: String) -> DatabaseReference{
        return databaseUser.child(uid)
    }
    
    /// узел messages в БД в Firebase Database
    var databaseMessage: DatabaseReference {
        return databaseRoot.child(REF_MESSAGE)
    }
    
    /// Возвращает узел  получателя, который хранит узел отправителя в узле messages в БД
    func databaseMessageSendTo(from: String, to: String) -> DatabaseReference{
        return databaseMessage.child(from).child(to)
    }
    
    /// узел inbox в БД в Firebase Database
    var databaseInbox: DatabaseReference {
        return databaseRoot.child(REF_INBOX)
    }
    
    /// Возвращает узел  получателя, который хранит узел отправителя в узле inbox в БД
    func databaseInboxInfo(from: String, to: String) -> DatabaseReference {
        return databaseInbox.child(from).child(to)
    }
    
    /// Возвращает узел конкретного юзера в узле inbox в БД в Firebase Database
    func databaseSpecificInboxForUser(uid: String) -> DatabaseReference{
        return databaseInbox.child(uid)
    }
    
    func databaseIsOnline(uid: String) -> DatabaseReference{
        return databaseUser.child(uid).child("isOnline")
    }
    
    var databaseGeo: DatabaseReference {
        return databaseRoot.child(REF_GEO)
    }
    
    //-------------------------- Storage Ref
    
    /// ссылка на мое хранение в Firebase Storage
    let storageRoot = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
    
    /// созданная папка profile в Storage в ней названия файлов - uid юзеров
    var storageProfile: StorageReference{
        return storageRoot.child(STORAGE_PROFILE)
    }
    
    /// Возвращает ссылку на детей(содержимое) из папки profile с нужным uid
    func storageSpecificProfile(uid: String) -> StorageReference{
        return storageProfile.child(uid)
    }
    
    /// созданная папка messages в Storage
    var storageMessage: StorageReference{
        return storageRoot.child(REF_MESSAGE)
    }
    
    /// В папке messages создаем папку photo, а в ней названия файлов - uid юзеров
    /// Возвращает ссылку в Storage на эти файлы
    func storageSpecificImageMessage(id: String) -> StorageReference{
        return storageMessage.child("photo").child(id)
    }
    
    func storageSpecificVideoMessage(id: String) -> StorageReference{
        return storageMessage.child("video").child(id)
    }
}
