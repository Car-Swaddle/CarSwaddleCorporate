//
//  LoginViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 5/9/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleData
import CarSwaddleUI

final class LoginViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: ActionButton!
    
    private var auth: Auth = Auth(serviceRequest: serviceRequest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction private func didTapLoginButton() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
            return
        }
        
        loginButton.isLoading = true
        
        store.privateContext { [weak self] privateContext in
            self?.auth.login(email: email, password: password, context: privateContext) { error in
                DispatchQueue.main.async {
                    self?.loginButton.isLoading = false
                }
                if error == nil {
                    DispatchQueue.main.async {
                        DataController.shared.updateAllData {
                            navigator.navigateToLoggedInViewController()
                        }
                    }
                }
            }
        }
    }
    
}
