//
//  SettingsViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/25/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

final class SettingsViewController: UIViewController, StoryboardInstantiating {
    
    @IBOutlet private weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailLabel.text = User.currentUser(context: store.mainContext)?.email
        
        emailLabel.font = .title
        emailLabel.textColor = .titleTextColor
    }
    
    @IBAction private func didTapLogout() {
        logout.logout()
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
