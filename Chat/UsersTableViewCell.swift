//
//  UsersTableViewCell.swift
//  Chat
//
//  Created by  mac on 2/2/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var onlineView: UIView!
    
    var user: User!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var controller: PeopleTableViewController!


    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 30
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
    
    override func prepareForReuse() {
           super.prepareForReuse()
           let refOnline = Ref().databaseIsOnline(uid: self.user.uid)
           if inboxChangedOnlineHandle != nil {
               refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
           }
        
            let refUser = Ref().databaseSpecificUser(uid: self.user.uid)
            if inboxChangedProfileHandle != nil {
                refUser.removeObserver(withHandle: inboxChangedProfileHandle)
            }
    }
    
    func loadData(_ user: User){
        self.user = user
        self.usernameLabel.text = user.username
        self.statusLabel.text = user.status
        self.avatar.contentMode = .scaleAspectFill
        self.avatar.loadImage(user.profileImageURL)
        self.avatar.loadImage(user.profileImageURL) { (image) in
            user.profileImage = image
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
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.tableView.reloadData()
            }
        })
    }

}
