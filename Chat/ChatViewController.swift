//
//  ChatViewController.swift
//  Chat
//
//  Created by  mac on 2/4/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation


class ChatViewController: UIViewController {
     
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var bottomView: UIView!
    
    
    var imagePartner: UIImage!
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var topLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    var partnerUsername: String!
    var partnerId: String!
    var isActive = false
    var lastTimeOnline = ""
    var isTyping = false
    var timer = Timer()
    
    var placeholderLabel = UILabel()
    var picker = UIImagePickerController()
    var messages = [Message]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        setupNavigationBar()
        setupInputContainer()
        setupTableView()
        observeMessages()
        if wallpaperName != nil {
            print (wallpaperName)
            let bgImageView = UIImageView(frame: tableView.frame)
            bgImageView.image = UIImage(named: wallpaperName!)
            tableView.backgroundView = bgImageView
        }
        inputTextView.layer.cornerRadius = 8
        inputTextView.clipsToBounds = true
        inputTextView.backgroundColor = .gray
    }
    
   
    
    
    
    // Подготовка перед появлением контроллера
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
    }

    // Подготовка перед закрытием контроллера

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Убираем клавиатуру по нажатию на пустом месте
        self.view.endEditing(true)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if let text = inputTextView.text, text != ""{
            inputTextView.text = ""
            self.textViewDidChange(inputTextView)
            sendToFireBase(dict: ["text": text as Any])
        }
    }
    @IBAction func mediaButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Chat", message: "Select source", preferredStyle: UIAlertController.Style.actionSheet)
        
        //picker.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        
        let camera = UIAlertAction(title: "Take a photo", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            }
            else {
                print("Camera is unavailable")
            }
        }
        
        let videoCamera = UIAlertAction(title: "Take a video", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                
                self.picker.sourceType = .camera
                self.picker.mediaTypes = [String(kUTTypeMovie)]
                self.picker.videoExportPreset = AVAssetExportPresetPassthrough
                self.picker.videoMaximumDuration = 30
                self.present(self.picker, animated: true, completion: nil)
            }
            else {
                print("Camera is unavailable")
            }
        }
        
        
        let library = UIAlertAction(title: "Choose a photo", style: UIAlertAction.Style.default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes = [String(kUTTypeMovie), String(kUTTypeImage)]
//                self.picker.videoExportPreset = AVAssetExportPresetPassthrough
//                self.picker.videoMaximumDuration = 30
                
                self.present(self.picker, animated: true, completion: nil)
            }
            else {
                print("Photo Library is unavailable")
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil )
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        alert.addAction(videoCamera)
        present(alert, animated: true, completion: nil)
    }
}
    
