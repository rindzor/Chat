//
//  ForgotPasswordViewController.swift
//  Chat
//
//  Created by  mac on 1/30/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import ProgressHUD
import JGProgressHUD

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
         
         func setupUI(){
             
             setupEmailTextField()
             setupResetButton()
         }
    
    @IBAction func dismissAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func resetPasswordPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if validateFields(){
            resetPassword(onSuccess: {
                ProgressHUD.showSuccess(SUCCESS_EMAIL_RESET)
                
                let hud = JGProgressHUD(style: .light)
                hud.textLabel.text = SUCCESS_EMAIL_RESET
                hud.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 2.0)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage)
                
                let hud = JGProgressHUD(style: .light)
                hud.textLabel.text = errorMessage
                hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 1)

            }
        }
    }
    

}
