//
//  ViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 5/9/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleData
import Authentication

final class ViewController: UIViewController {
    
    private var network: UserNetwork = UserNetwork(serviceRequest: serviceRequest)

    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AuthController().token == nil {
            let loginViewController = LoginViewController.viewControllerFromStoryboard()
            present(loginViewController, animated: true, completion: nil)
        }
        
    }


}

