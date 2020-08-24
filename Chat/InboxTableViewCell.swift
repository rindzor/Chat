//
//  InboxTableViewCell.swift
//  Chat
//
//  Created by  mac on 2/10/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import Firebase

class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var onlineView: UIView!
    
    var user: User!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var inboxChangedMessageHandle: DatabaseHandle!
    var inbox: Inbox!
    var controller: MessageTableViewController!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatar.layer.cornerRadius = 30
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        
        onlineView.layer.cornerRadius = 7.5
        onlineView.backgroundColor = .red
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.white.cgColor
        onlineView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(uid: String, inbox: Inbox){
        self.user = inbox.user
        self.inbox = inbox
        avatar.loadImage(inbox.user.profileImageURL)
        usernameLabel.text = inbox.user.username
        
        
        let date = Date(timeIntervalSince1970: inbox.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLabel.text = dateString
        
        if inbox.text.isEmpty{
            messageLabel.text = "Photo message"
        }
        else {
            messageLabel.text = inbox.text
        }
        
        //Мониторим онлайн статус в реальном времени в окне чата из БД
        let refOnline = Ref().databaseIsOnline(uid: user.uid)
        refOnline.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any>{
                if let active = snap["online"] as? Bool{
                    self.onlineView.backgroundColor = (active == true) ? .green : .red
                }
            }
        }
        
        if inboxChangedOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        
        // Мониторим онлайн статус при входе/выходе из приложения без обновления страницы
        inboxChangedOnlineHandle = refOnline.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.onlineView.backgroundColor = (snap as! Bool == true) ? .green : .red
                }
            }
        }
        
        
        //Обновление пользовательски данных в реальном времени
        let refUser = Ref().databaseSpecificUser(uid: inbox.user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
            }
        })
        
        
        //Обновление сообщений в реальном времени
        let refInbox = Ref().databaseInboxInfo(from: Api.User.currentUserId, to: inbox.user.uid)
        if inboxChangedMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangedMessageHandle)
        }
         
        inboxChangedMessageHandle = refInbox.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value{
                self.inbox.updateData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
            }
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let refOnline = Ref().databaseIsOnline(uid: self.inbox.user.uid)
        if inboxChangedOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        let refUser = Ref().databaseSpecificUser(uid: inbox.user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        let refMessage = Ref().databaseInboxInfo(from: Api.User.currentUserId, to: inbox.user.uid)
        if inboxChangedMessageHandle != nil {
            refMessage.removeObserver(withHandle: inboxChangedMessageHandle)
        }
    }

}
