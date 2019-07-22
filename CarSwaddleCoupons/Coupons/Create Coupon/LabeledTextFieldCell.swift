//
//  LabeledTextFieldCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 7/22/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import CarSwaddleUI

final class LabeledTextFieldCell: UITableViewCell, NibRegisterable {
    
    var textChanged: (_ text: String?) -> Void = { _ in }
    
    @IBOutlet public var labeledTextField: LabeledTextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        labeledTextField.textField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
        selectionStyle = .none
    }
    
    
    @objc private func didChangeText(_ textField: UITextField) {
        textChanged(textField.text)
    }
    
}
