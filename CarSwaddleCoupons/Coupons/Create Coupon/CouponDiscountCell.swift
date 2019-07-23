//
//  CouponDiscountCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 7/22/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import CarSwaddleUI
import CarSwaddleNetworkRequest
import CarSwaddleData

private let dollarSymbol = NSLocalizedString("$", comment: "Dollary sign")
private let percentSymbol = NSLocalizedString("%", comment: "Percent symbol")

class CouponDiscountCell: UITableViewCell, NibRegisterable {
    
    public var discountDidChange: (_ discount: CouponNetwork.CouponDiscount?) -> Void = { _ in }
//    public var discount: CouponNetwork.CouponDiscount = .amountOff(value: 0)

    @IBOutlet private weak var symbolLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        segmentedControl.addTarget(self, action: #selector(typeDidChange), for: .valueChanged)
    }
    
    @objc private func typeDidChange() {
        updateForCurrentDiscount()
    }
    
    @objc private func textChanged() {
        updateForCurrentDiscount()
    }
    
    private func updateForCurrentDiscount() {
        guard let integerText = textField.text?.intValue else { return }
        var discount: CouponNetwork.CouponDiscount
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            discount = CouponNetwork.CouponDiscount.amountOff(value: integerText.dollarsToCents)
        case 1:
            discount = CouponNetwork.CouponDiscount.percentOff(value: integerText)
        default: return
        }
        discountDidChange(discount)
        configure(with: discount)
    }
    
    public func configure(with discount: CouponNetwork.CouponDiscount) {
        switch discount {
        case .amountOff(let amount):
            textField.text = amount.centsToDollars.stringValue
            symbolLabel.text = dollarSymbol
        case .percentOff(let percent):
            textField.text = percent.stringValue
            symbolLabel.text = percentSymbol
        }
    }
    
}
