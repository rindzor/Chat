//
//  ChatViewController+Extension.swift
//  Chat
//
//  Created by  mac on 2/9/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import UIKit

extension ChatViewController{
    // Загружает сообщения
   func observeMessages(){
    //Если переписка с самим собой
    if Api.User.currentUserId == partnerId{
        Api.Message.recieveMessage(from: Api.User.currentUserId, to: partnerId) { (message) in
            print(message.id)
            self.messages.append(message)
            self.sortMessages()
        }
    }
    //Если переписка другим человеком
    else {
       Api.Message.recieveMessage(from: Api.User.currentUserId, to: partnerId) { (message) in
           print(message.id)
           self.messages.append(message)
           self.sortMessages()
       }
       Api.Message.recieveMessage(from: partnerId, to: Api.User.currentUserId) { (message) in
           print(message.id)
           self.messages.append(message)
           self.sortMessages()
       }
    }

   }
   
   func sortMessages(){
       messages = messages.sorted(by: {$0.date < $1.date })
       DispatchQueue.main.async {
           self.tableView.reloadData()
           self.scrollToBottom()
       }
   }
   
    func scrollToBottom(){
        if messages.count > 0{
            let index = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: false)
        }
    }
    
   func setupPicker(){
       picker.delegate = self
   }
       
   func setupTableView(){
       
       tableView.tableFooterView = UIView()
        //При нажатии ячейки не выделяются
        tableView.allowsSelection = false
       // без разделяющих линий
       tableView.separatorStyle = .none
       // Для того чтобы вызвать extensions UITableViewDataSource, UITableViewDelegate
       tableView.delegate = self
       tableView.dataSource = self
   }
       
   func setupInputContainer(){
       let mediaImg = UIImage.init(systemName: "paperclip")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
       mediaButton.setImage(mediaImg, for: UIControl.State.normal)
       mediaButton.tintColor = .lightGray
       
       let micImg = UIImage.init(systemName: "mic")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
       audioButton.setImage(micImg, for: UIControl.State.normal)
       audioButton.tintColor = .lightGray
       
       setupInputTextView()
   }
   
   func setupInputTextView(){
       
       inputTextView.delegate = self
    
     
       
       placeholderLabel.isHidden = false
       let placeholderX: CGFloat = self.view.frame.size.width / 75
       let placeholderY: CGFloat = 0
       let placeholderWidth: CGFloat = inputTextView.bounds.width - placeholderX
       let placeholderHeight: CGFloat = inputTextView.bounds.height
       let placeholderFontSize = self.view.frame.size.width / 25
       
       placeholderLabel.frame =  CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
       placeholderLabel.text = "Start chatting"
       placeholderLabel.font = UIFont(name: "HelveticaNeue", size: placeholderFontSize)
       placeholderLabel.textColor = UIColor.lightGray
       placeholderLabel.textAlignment = .left
       
       inputTextView.addSubview(placeholderLabel)
       
       
   }
   
   func setupNavigationBar(){
       navigationItem.largeTitleDisplayMode = .never
       let containView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
       avatarImageView.image = imagePartner
       avatarImageView.contentMode = .scaleAspectFill
       avatarImageView.layer.cornerRadius = 18
       avatarImageView.clipsToBounds = true
       containView.addSubview(avatarImageView)
       
       let rightBarButton = UIBarButtonItem(customView: containView)
       self.navigationItem.rightBarButtonItem = rightBarButton
       
       observeOnlineStatus()
       updateOnlineLabel(bool: false)

       self.navigationItem.titleView = topLabel
   }
    
    func updateOnlineLabel(bool: Bool){
        var status = ""
        var color = UIColor()
        if bool{
            status = "Online"
            color = .green
            if isTyping{
                status = "Typing..."
                color = .gray
            }
        }
        else {
            status = "Last Active " + self.lastTimeOnline
            color = .red
        }
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 0
        let attributedTitle = NSMutableAttributedString(string: partnerUsername + "\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black])
        let attributedSubTitle = NSMutableAttributedString(string: status, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : color])
        attributedTitle.append(attributedSubTitle)
        
        topLabel.attributedText = attributedTitle
    }
    
    func observeOnlineStatus(){
        
        //Мониторим онлайн статус в реальном времени в окне чата из БД
        let ref = Ref().databaseIsOnline(uid: partnerId)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any>{
                if let active = snap["online"] as? Bool{
                    self.isActive = active
                }
                if let latest = snap["latest"] as? Double{
                    self.lastTimeOnline = latest.convertDate()
                }
                
            }
                self.updateOnlineLabel(bool: self.isActive)
        }
        
        // Мониторим онлайн статус при входе/выходе из приложения без обновления страницы
        ref.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.isActive = snap as! Bool
                }
                if snapshot.key == "latest" {
                    let latest = snap as! Double
                    self.lastTimeOnline = latest.convertDate()
                }
                if snapshot.key == "typing"{
                    let typing = snap as! String
                    self.isTyping = typing == Api.User.currentUserId ? true : false
                }
                self.updateOnlineLabel(bool: self.isActive)
            }
        }
    }

    
    func sendToFireBase(dict: Dictionary<String, Any>){
            
        let date = Date().timeIntervalSince1970 // Текущая дата
        var value = dict                        // Временный словаь
        
        value["from"] = Api.User.currentUserId  // От кого
        value["to"] = partnerId                 // Кому
        value["date"] = date                    // Дата
        value["read"] = true                    // Прочитано?
        Api.Message.sendMessage(from: Api.User.currentUserId, to: partnerId, value: value)
    }
}

//MARK: - UITextViewDelegate

    extension ChatViewController: UITextViewDelegate{
        func textViewDidChange(_ textView: UITextView) {
            let spacing = CharacterSet.whitespacesAndNewlines
            if !textView.text.trimmingCharacters(in: spacing).isEmpty{
                let text = textView.text.trimmingCharacters(in: spacing)
                sendButton.isEnabled = true
                sendButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
                placeholderLabel.isHidden = true
            }
            else{
                sendButton.isEnabled = false
                sendButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
                placeholderLabel.isHidden = false
            }
            
            if !isTyping {
                Api.User.typing(from: Api.User.currentUserId, to: partnerId)
                isTyping = true
            }
            else {
                timer.invalidate()
            }
            timerTyping()
        }
        
        func timerTyping() {
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (t) in
                Api.User.typing(from: Api.User.currentUserId, to: "")
                self.isTyping = false
            })
        }
        
    }



    //MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

    extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        
        // Вызывается, когда пользователь выбрал фото или видео
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                print("+++++++++++++++++++++")
                //print(videoUrl)
                print("+++++++++++++++++++++")
                handleVideoSelectedForUrl(videoUrl)
            }
            else {
                handleImageSelectedForInfo(info)
            }
        }
        
        func handleVideoSelectedForUrl(_ url: URL){
            let videoName = NSUUID().uuidString
            StorageService.saveVideoMessage(url: url, id: videoName, onSuccess: { (anyValue) in
                if let dict = anyValue as? [String: Any] {
                    self.sendToFireBase(dict: dict)
                }
            }) { (errorMessage) in
                
            }
            self.picker.dismiss(animated: true, completion: nil)
            
        }
        
        // обрабатывае выбранное фото
        func handleImageSelectedForInfo(_ info:  [UIImagePickerController.InfoKey : Any]){
            
            // Отвечает за выбранное фото
            var selectedImageFromPicker: UIImage?
            //Если фото было модифицировано
            if let imageEditedSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
                selectedImageFromPicker = imageEditedSelected
            }
            //Если фото не было модифицировано
            if let imageOriginalSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                selectedImageFromPicker  = imageOriginalSelected
            }
            
            // Это будет уникальное название файла с фото в Storage
            let imageName = NSUUID().uuidString
            
            // Сохраняем фото в БД
            StorageService.savePhotoMessage(image: selectedImageFromPicker, id: imageName, onSuccess: { (anyValue) in
                if let dict = anyValue as? [String: Any]{
                    self.sendToFireBase(dict: dict)
                }
            }) { (errorMessage) in
                
            }
            
            self.picker.dismiss(animated: true, completion: nil)
        }
    }


    //MARK: - UITableViewDataSource, UITableViewDelegate

    extension ChatViewController: UITableViewDataSource, UITableViewDelegate{
        
        // Возвращает количество строчек в table
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }
        
        // Provide a cell object for each row.
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            //Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
            cell.configureCell(uid: Api.User.currentUserId, message: messages[indexPath.row], image: imagePartner)
            return cell
        }
        
        // Asks the delegate for the height to use for a row in a specified location
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            var height: CGFloat = 0
            var message = messages[indexPath.row]
            let text = message.text
            if !text.isEmpty{
                height = text.estimateFrameForText(text).height + 60 // 60 is padding
            }
            
            let heightMessage = message.height
            let widthMessage = message.width
            if heightMessage != 0, widthMessage != 0{
                height = CGFloat(heightMessage / widthMessage * 250)
            }
            return height
        }

    }

extension Double{
    func convertDate() -> String{
        var string = ""
        let date: Date = Date(timeIntervalSince1970: self)
        let calendar = Calendar.current
        let formatter = DateFormatter()
        if calendar.isDateInToday(date){
            string = ""
            formatter.timeStyle = .short
        }
        else if calendar.isDateInYesterday(date){
            string = "Yesterday: "
            formatter.timeStyle = .short
        }
        else{
            formatter.timeStyle = .short
        }
        let dateString = formatter.string(from: date)
        return string + dateString
    }
}
