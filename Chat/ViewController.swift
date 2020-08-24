//
//  ViewController.swift
//  Chat
//
//  Created by  mac on 1/29/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInFacebookButton: UIButton!
    @IBOutlet weak var signInGoogleButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let storyboard = UIStoryboard(name: "OnBoarding", bundle: nil)
        if let walkthroughVC = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            self.navigationController?.modalPresentationStyle = .fullScreen
            self.navigationController?.present(walkthroughVC, animated: true, completion: nil)
        }
    }

   
    
    func setupUI(){
        setupHeaderTitle()
        setupOrLabel()
        setupTermsLabel()
        setupFacebookButton()
        setupGoogleButton()
        setupCreateAccountButton()
    }

}

