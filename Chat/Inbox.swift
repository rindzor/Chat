//
//  Inbox.swift
//  Chat
//
//  Created by  mac on 2/10/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation

class Inbox{
    var date: Double
    var text: String
    var user: User
    var read = false
    
    init(date: Double, text: String, user: User, read: Bool){
        self.date = date
        self.text = text
        self.user = user
        self.read = read
    }
    
    static func transformInbox(dict: [String: Any], user: User) -> Inbox? {
        // Из словаря dict защищенным способом получаем нужные поля, названия полей важно, так как должно соответствовать этим именам из БД
        guard let date = dict["date"] as? Double,
              let text = dict["text"] as? String,
              let read = dict["read"] as? Bool else {
                return nil
        }
        // Инициализируем inbox
        let inbox = Inbox(date: date, text: text, user: user, read: read)
        
        return inbox
    }
    
    func updateData(key: String, value: Any){
       switch key {
       case "date": self.date = value as! Double
       case "text": self.text = value as! String
       default: break
       }
    }
}

