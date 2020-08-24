//
//  MessageApi.swift
//  Chat
//
//  Created by  mac on 2/5/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import Firebase

class MessageApi{
    
    func sendMessage(from: String, to: String, value: Dictionary<String, Any>){
        
        /// Возвращает узел отправителя, который хранит узел получателя в узле messages в БД
        let ref = Ref().databaseMessageSendTo(from: from, to: to)
        ref.childByAutoId().updateChildValues(value)
        
        var dict = value
        
        // Если отправляем текстовое сообщение, данные о фото не нужны в базе
        if let text = dict["text"] as? String, text.isEmpty {
            dict["width"] = nil
            dict["height"] = nil
            dict["imageUrl"] = nil
            
        }
        
        let refFrom = Ref().databaseInboxInfo(from: from, to: to)
        refFrom.updateChildValues(dict)
        
        let refTo = Ref().databaseInboxInfo(from: to, to: from)
        refTo.updateChildValues(dict)
    }
    
    func recieveMessage(from: String, to: String, onSuccess: @escaping(Message) -> Void){
        let ref = Ref().databaseMessageSendTo(from: from, to: to)
        ref.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                if let message = Message.transformMessage(dict: dict, keyId: snapshot.key){
                    onSuccess(message)
                }
            }
        }
    }
}
