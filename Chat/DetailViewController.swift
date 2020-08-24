//
//  DetailViewController.swift
//  Chat
//
//  Created by  mac on 2/19/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.layer.cornerRadius = 5
        sendButton.clipsToBounds = true
        
        let backImg = UIImage(systemName: "xmark")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backButton.setImage(backImg, for: UIControl.State.normal)
        backButton.tintColor = .white
        backButton.layer.cornerRadius = 35/2
        backButton.clipsToBounds = true
        
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
//        blurredEffectView.frame = backButton.bounds
        //view.addSubview(blurredEffectView)
        
        
        avatar.image = user.profileImage
        avatar.contentMode = .scaleAspectFill
        let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350)
        avatar.addBlackGradientLayer(frame: frameGradient, colors: [.clear, .black])
        
        usernameLabel.text = user.username
        if user.age != nil {
            ageLabel.text = "\(user.age!)"
        }
        else {
            ageLabel.text = ""
        }
        if let isMale = user.isMale {
            var genderImgSystemName = (isMale == true) ? "m.square.fill" : "f.square.fill"
            genderImage.image = UIImage(systemName: genderImgSystemName)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        }
        genderImage.tintColor = .gray
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {

       let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
       let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
       chatVC.imagePartner = avatar.image
       chatVC.partnerUsername = usernameLabel.text
       chatVC.partnerId = user.uid
       // Перебрасываем пользователя на ChatViewController
       self.navigationController?.pushViewController(chatVC, animated: true)
       
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - UITableViewDataSource, UITableViewDelegate

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapTableViewCell
        if !user.latitue.isEmpty, !user.longitude.isEmpty {
            let location = CLLocation(latitude: CLLocationDegrees(Double(user.latitue)!), longitude: CLLocationDegrees(Double(user.longitude)!))
            cell.configure(location: location)
        }
        cell.selectionStyle = .none
        cell.controller = self
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
}
