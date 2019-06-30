//
//  RequestAuthorityCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/24/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import Store

class RequestAuthorityCell: UITableViewCell, NibRegisterable {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel?.font = UIFont.appFont(type: .regular, size: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
    
    func configure(with authority: Authority.Name) {
        textLabel?.text = authority.localizedString
    }
    
}


extension Authority.Name {
    
    public var localizedString: String {
        switch self {
        case .createCoupons:
            return NSLocalizedString("Create Coupons", comment: "An authority")
        case .editAuthorities:
            return NSLocalizedString("Edit Authorities", comment: "An authority")
        case .readAuthorities:
            return NSLocalizedString("Read Authorities", comment: "An authority")
        case .readMechanics:
            return NSLocalizedString("Read Mechanics", comment: "An authority")
        case .editMechanics:
            return NSLocalizedString("Edit Mechanics", comment: "An authority")
        }
    }
    
}
