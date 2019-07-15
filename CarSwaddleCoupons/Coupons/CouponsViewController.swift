//
//  CouponsViewController.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/1/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

class CouponsViewController: FetchedResultsTableViewController<Coupon> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(<#T##nibRegisterable: (UITableViewCell & NibRegisterable).Type##(UITableViewCell & NibRegisterable).Type#>)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}
