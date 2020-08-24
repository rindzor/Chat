//
//  MessageTableViewController.swift
//  Chat
//
//  Created by  mac on 2/2/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import FirebaseAuth

class MessageTableViewController: UITableViewController {
    
    var inboxArray = [Inbox]()
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        observeInbox()
        
    }

    func setupNavigationBar(){
        navigationItem.title = "Chats"
        navigationController?.navigationBar.prefersLargeTitles = true
         
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        if let currentUser = Auth.auth().currentUser {
            let photoURL = currentUser.photoURL
            avatarImageView.loadImage(photoURL?.absoluteString)
        }
        containView.addSubview(avatarImageView)
        
        let rightBarButton = UIBarButtonItem(customView: containView)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        // Меняем фото в правом верхнем углу в реальном времени
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name("updateProfileImage"), object: nil)
    }
    
    @objc func updateProfile(){
        if let currentUser = Auth.auth().currentUser {
            let photoURL = currentUser.photoURL
            avatarImageView.loadImage(photoURL?.absoluteString)
        }
    }
    
    func setupTableView(){
        
        tableView.tableFooterView = UIView()
    }
    
    func observeInbox(){
        Api.Inbox.lastMessages(uid: Api.User.currentUserId) { (inbox) in
            if !self.inboxArray.contains(where: { $0.user.uid == inbox.user.uid}){
                self.inboxArray.append(inbox)
                // без этого не появляется на вьюхе
                self.sortedInbox()
            }
        }
    }
    
    func sortedInbox(){
         inboxArray = inboxArray.sorted(by: {$0.date > $1.date })
         DispatchQueue.main.async {
             self.tableView.reloadData()
         }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print(self.inboxArray.count)
        return self.inboxArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // Defining the cell...
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxTableViewCell", for: indexPath) as! InboxTableViewCell
        
        // Configure the cell...
        
        let inbox = inboxArray[indexPath.row]
//        print("--------------------------------")
//        print(inbox.text)
//        print("--------------------------------")
        cell.controller = self
        cell.configureCell(uid: Api.User.currentUserId, inbox: inbox)
        
        
        return cell
    }
    
    // Вызывается, когда выбираем определенную строку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           if let cell = tableView.cellForRow(at: indexPath) as? InboxTableViewCell{

               let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
               let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
               chatVC.imagePartner = cell.avatar.image
               chatVC.partnerUsername = cell.usernameLabel.text
               chatVC.partnerId = cell.user.uid
               // Перебрасываем пользователя на ChatViewController
               self.navigationController?.pushViewController(chatVC, animated: true)
           }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
