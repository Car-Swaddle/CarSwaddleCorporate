//
//  CouponCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 7/14/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import CarSwaddleUI
import Store

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

let percentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

let monthDayYearDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M-dd-YYYY"
    return formatter
}()


private let amountOffString = NSLocalizedString("%@ off", comment: "")
private let percentOffString = NSLocalizedString("%@ off", comment: "")
private let discountBookingFeeString = NSLocalizedString("Remove booking fee", comment: "")
private let requiredMechanicString = NSLocalizedString("Required mechanic: %@", comment: "")
private let redemptionsLeftString = NSLocalizedString("%d redemptions left", comment: "")


final class CouponCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var couponCodeLabel: UILabel!
    @IBOutlet private weak var couponNameLabel: UILabel!
    @IBOutlet private weak var discountLabel: UILabel!
    @IBOutlet private weak var removeBookingFeeLabel: UILabel!
    @IBOutlet private weak var redemptionsLabel: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private weak var requiredMechanicLabel: UILabel!
    
    private var coupon: Coupon?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        couponCodeLabel.font = .large
        couponCodeLabel.textColor = .selectionColor
        discountLabel.font = .large
        discountLabel.textColor = .largeTextColor
        couponNameLabel.font = .title
        couponNameLabel.textColor = .titleTextColor
        removeBookingFeeLabel.font = .detail
        removeBookingFeeLabel.textColor = .detailTextColor
        redemptionsLabel.font = .detail
        redemptionsLabel.textColor = .detailTextColor
        expirationDateLabel.font = .detail
        expirationDateLabel.textColor = .detailTextColor
        requiredMechanicLabel.font = .detail
        requiredMechanicLabel.textColor = .detailTextColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CouponCell.didTapCouponLabel(_:)))
        couponCodeLabel.isUserInteractionEnabled = true
        couponCodeLabel.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        coupon = nil
    }
    
    func configure(with coupon: Coupon) {
        self.coupon = coupon
        
        couponCodeLabel.text = coupon.identifier
        couponNameLabel.text = coupon.name
        discountLabel.text = self.discountLabel(with: coupon)
        removeBookingFeeLabel.text = coupon.discountBookingFee ? discountBookingFeeString : nil
        
        if coupon.numberOfRedemptionsLeft == 0 {
            redemptionsLabel.textColor = .errorTextColor
        } else {
            redemptionsLabel.textColor = .detailTextColor
        }
        redemptionsLabel.text = self.redemptionsLeft(with: coupon)
        
        expirationDateLabel.text = coupon.redeemByString
        
        if coupon.redeemBy.isInPast {
            expirationDateLabel.textColor = .errorTextColor
        } else {
            expirationDateLabel.textColor = .detailTextColor
        }
        
        let required = requiredMechanicString(with: coupon)
        requiredMechanicLabel.text = required
        requiredMechanicLabel.isHiddenInStackView = required == nil ? false : true
    }
    
    private func discountLabel(with coupon: Coupon) -> String? {
        if let amountOff = coupon.amountOff?.centsToDollars,
            let formattedAmountOff = currencyFormatter.string(from: amountOff) {
            return String(format: amountOffString, formattedAmountOff)
        } else if let percentOff = coupon.percentOff {
            return String(format: percentOffString, percentFormatter.string(from: NSNumber(value: Float(percentOff))) ?? "")
        }
        return nil
    }
    
    private func redemptionsLeft(with coupon: Coupon) -> String? {
        guard let redemptionsLeft = coupon.numberOfRedemptionsLeft else { return nil }
        return String(format: redemptionsLeftString, redemptionsLeft)
    }
    
    @objc private func didTapCouponLabel(_ tapGesture: UITapGestureRecognizer) {
        showCopyMenu()
    }
    
    public func showCopyMenu() {
        let menu = UIMenuController.shared
        menu.setTargetRect(couponCodeLabel.frame, in: couponCodeLabel)
        menu.setMenuVisible(true, animated: true)
        couponCodeLabel.becomeFirstResponder()
    }
    
    private func requiredMechanicString(with coupon: Coupon) -> String? {
        return nil
//        guard let redemptionsLeft = coupon.createdBy else { return nil }
//        return redemptionsLeft.stringValue
    }
    
}

extension Coupon {
    
    private static let expiredString = NSLocalizedString("expires %@", comment: "")
    private static let expiredInPastString = NSLocalizedString("expired %@", comment: "")
    
    var numberOfRedemptionsLeft: Int? {
        if let maxRedemptions = maxRedemptions {
            return maxRedemptions - redemptions
        }
        return nil
    }
    
    var redeemByString: String {
        if redeemBy.isInPast {
            return String(format: Coupon.expiredInPastString, monthDayYearDateFormatter.string(from: redeemBy))
        } else {
            return String(format: Coupon.expiredString, monthDayYearDateFormatter.string(from: redeemBy))
        }
    }
    
}

extension Date {
    
    public var isInPast: Bool {
        return self < Date()
    }
    
}


public extension Int {
    
    var centsToDollars: NSDecimalNumber {
        return NSDecimalNumber(value: Float(self) / 100.0)
    }
    
}

public extension Int {
    
    var dollarsToCents: Int {
        return self * 100
    }
    
}


class HipsterLabel : UILabel {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(UIResponderStandardEditActions.copy(_:)))
    }
    
    // MARK: - UIResponderStandardEditActions
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
    
}
