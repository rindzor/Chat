//
//  InboxApi.swift
//  Chat
//
//  Created by  mac on 2/10/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import Firebase

typealias InboxCompletion = (Inbox) -> Void

class InboxApi {
    func lastMessages(uid: String, onSuccess: @escaping(InboxCompletion)){
        let ref = Ref().databaseSpecificInboxForUser(uid: uid)
        ref.observe(DataEventType.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                print("++++")
                print(dict)
                print("++++")
                // snapshot.key is a partner id
                // | we
                // | - Partner id
                Api.User.getUserInfo(uid: snapshot.key) { (user) in
                    if let inbox = Inbox.transformInbox(dict: dict, user: user){
                        onSuccess(inbox)
                    }
                }
            }
        }
    }
}
