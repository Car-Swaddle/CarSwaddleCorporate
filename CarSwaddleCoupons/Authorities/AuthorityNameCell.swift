//
//  AuthorityNameCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/3/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleStore
import CarSwaddleData
import UIKit

class AuthorityNameCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var authorityNameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        emailLabel.detailStyled()
        authorityNameLabel.largeStyled()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with authority: Authority) {
        authorityNameLabel.text = authority.name
        emailLabel.text = authority.user?.email
    }
    
}
