//
//  StorageService.swift
//  Chat
//
//  Created by  mac on 2/1/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
import AVFoundation

class StorageService{
    
    // Сохраняет фото в БД, в случае успеха onSuccess вернет словарь, описывающий это фото
    static func savePhotoMessage(image: UIImage?, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        if let imagePhoto = image {
            
            // Ссылка на файл в Storage в папке messages -> photo
            let ref = Ref().storageSpecificImageMessage(id: id)
            
            // Сжимаем изображение
            if let data = imagePhoto.jpegData(compressionQuality: 0.5){
                ref.putData(data, metadata: nil) { (storageMetadata, error) in
                    if error != nil {
                        onError(error!.localizedDescription)
                    }
                    ref.downloadURL { (url, error ) in
                        if let metaImageUrl = url?.absoluteString{
                            let dict: Dictionary<String, Any> = [
                                "imageUrl": metaImageUrl as Any,
                                "height": imagePhoto.size.height as Any,
                                "width": imagePhoto.size.width as Any,
                                "text": "" as Any
                            ]
                            onSuccess(dict)
                        }
                    }
                }
            }
        }
    }
    
    static func saveVideoMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        
        let ref = Ref().storageSpecificVideoMessage(id: id)
        ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil{
                print("-----------------------------------------------------------")
                onError(error!.localizedDescription)
                print("-----------------------------------------------------------")
            }
            ref.downloadURL { (videoUrl, error) in
                if error != nil{
                    print("-----------------------------------------------------------")
                    print(error?.localizedDescription)
                    print("-----------------------------------------------------------")
                }
                if let thumbnailImage = self.thumbnailImageForFileUrl(url){
                    StorageService.savePhotoMessage(image: thumbnailImage, id: id, onSuccess: { (value) in
                        if let dict = value as? Dictionary<String, Any> {
                            var dictValue = dict
                            guard let videoUrlString = videoUrl?.absoluteString else {
                                print("-----------------------------------------------------------")
                                print(error!.localizedDescription)
                                print("-----------------------------------------------------------")
                                print(dictValue)
                                print("-----------------------------------------------------------")
                                return
                            }
                                print("-----------------------------------------------------------")
                                print(videoUrlString)
                                print("-----------------------------------------------------------")
                                dictValue["videoUrl"] = videoUrlString
                            
                            onSuccess(dictValue)
                        }
                        
                    }) { (errorMessage) in
                        onError(errorMessage)
                    }
                }
            }
          
        }
    }
    
    static func thumbnailImageForFileUrl(_ url: URL) -> UIImage?{
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError{
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    static func saveNewPhoto(image: UIImage, uid: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
            
            // Ссылка на юзера (файл юзера) в папке profile
        let storageProfileRef = Ref().storageSpecificProfile(uid: uid)
            
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        storageProfileRef.putData(imageData, metadata: metadata) { (storageMetadata, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            // Пытаемся получить досутп к URL фото юзера, выгруженного в наш Storage
            storageProfileRef.downloadURL { (url, error) in
                if error != nil{
                    print(error?.localizedDescription )
                    return
                }
                
                // Получаем досутп к URL фото, выгруженного в наш Storage
                if let metaImageUrl = url?.absoluteString{
                    
                     // обновляем информацию юзера
                     if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
                         changeRequest.photoURL = url
                         
                         // коммитим изменения
                         changeRequest.commitChanges { (error) in
                             if let error = error{
                                 ProgressHUD.showError(error.localizedDescription)
                             }
                             else{
                                NotificationCenter.default.post(name: NSNotification.Name("updateProfileImage"), object: nil)
                             }
                            
                         }
                 }
                    
                 // обновляем данные юзера хранящегося в нашей БД по такой схеме:
                 //  - chat
                 //    | -users
                 //       | - uid1
                 //       | - uid2
                 //       ........
                 //       | - uidn
                 
                    Ref().databaseSpecificUser(uid: uid).updateChildValues([PROFILE_IMAGE_URL: metaImageUrl]) { (error, databaseReference) in
                        if error == nil{
                         
                         // onSuccess() идет по цепочке до самого первого вызова
                         // В обратном направлении цепочка имеет вид:
                         // savePhoto() -> signUp()
                            onSuccess()
                        }
                        else{
                         // onError() идет по цепочке до первой ошибки
                            onError(error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    static func savePhoto(username: String, uid: String, data: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        
        // Заносим данные о выбранном изображении в storageProfileRef (файл с юзером)
       storageProfileRef.putData(data, metadata: metadata) { (storageMetadata, error) in
           if error != nil{
               onError(error!.localizedDescription)
               return
           }
           
           // Пытаемся получить досутп к URL фото юзера, выгруженного в наш Storage
           storageProfileRef.downloadURL { (url, error) in
               if error != nil{
                   print(error?.localizedDescription )
                   return
               }
               
               // Получаем досутп к URL фото, выгруженного в наш Storage
               if let metaImageUrl = url?.absoluteString{
                   
                    // обновляем информацию юзера
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
                        changeRequest.photoURL = url
                        changeRequest.displayName = username
                        
                        // коммитим изменения
                        changeRequest.commitChanges { (error) in
                            if let error = error{
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        }
                }
                   
                   // Присваиваем пользователю в словаре dictTemp ссылку на изображение, заранее приравняв его к словарю dict
                   var dictTemp = dict
                   dictTemp[PROFILE_IMAGE_URL] = metaImageUrl
                  
                // обновляем данные юзера хранящегося в нашей БД по такой схеме:
                //  - chat
                //    | -users
                //       | - uid1
                //       | - uid2
                //       ........
                //       | - uidn
                
                   Ref().databaseSpecificUser(uid: uid).updateChildValues(dictTemp) { (error, databaseReference) in
                       if error == nil{
                        
                        // onSuccess() идет по цепочке до самого первого вызова
                        // В обратном направлении цепочка имеет вид:
                        // savePhoto() -> signUp()
                           onSuccess()
                       }
                       else{
                        // onError() идет по цепочке до первой ошибки
                           onError(error!.localizedDescription)
                       }
                   }
               }
           }
       }
    }
}
