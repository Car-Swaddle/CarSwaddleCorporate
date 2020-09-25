//
//  SwitchCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 7/22/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import CarSwaddleUI
import UIKit

class SwitchCell: UITableViewCell, NibRegisterable {
    
    public var labelText: String? {
        didSet {
            switchLabel.text = labelText
        }
    }
    
    var switchIsOn: Bool = false {
        didSet {
            isOnSwitch.isOn = switchIsOn
        }
    }
    
    public var switchDidChange: (_ isOn: Bool) -> Void = { _ in }

    @IBOutlet private weak var switchLabel: UILabel!
    @IBOutlet private weak var isOnSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isOnSwitch.addTarget(self, action: #selector(didChangeSwitch), for: .valueChanged)
        selectionStyle = .none
    }
    
    
    @objc private func didChangeSwitch() {
        switchDidChange(isOnSwitch.isOn)
    }
    
    
}
