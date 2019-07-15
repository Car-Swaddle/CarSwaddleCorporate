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
import CoreData

private let subduedBackgroundColor: UIColor = .gray1
private let regularBackgroundColor: UIColor = .white

private let currentUserHasAuthorityString = NSLocalizedString("You already have this authority", comment: "The current user has the authority displayed nearby")

class RequestAuthorityCell: UITableViewCell, NibRegisterable {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel?.font = .large
        textLabel?.numberOfLines = 0
        detailTextLabel?.font = .detail
        selectionStyle = .none
        detailTextLabel?.textColor = .gray4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
    
    func configure(with authority: Authority.Name) {
        textLabel?.text = authority.localizedString
        detailTextLabel?.text = self.detailText(for: authority)
        
        textLabel?.font = textLabelFont(for: authority)
        textLabel?.textColor = self.titleTextColor(for: authority)
        backgroundColor = self.backgroundColor(for: authority)
    }
    
    private func textLabelFont(for authority: Authority.Name) -> UIFont {
        if authority.currentUserHasAuthority(in: store.mainContext) {
            return .title
        } else {
            return .large
        }
    }
    
    private func detailText(for authority: Authority.Name) -> String? {
        if authority.currentUserHasAuthority(in: store.mainContext) {
            return currentUserHasAuthorityString
        } else {
            return nil
        }
    }
    
    private func backgroundColor(for authority: Authority.Name) -> UIColor {
        if authority.currentUserHasAuthority(in: store.mainContext) {
            return subduedBackgroundColor
        } else {
            return regularBackgroundColor
        }
    }
    
    private func titleTextColor(for authority: Authority.Name) -> UIColor {
        if authority.currentUserHasAuthority(in: store.mainContext) {
            return .gray4
        } else {
            return .black
        }
    }
    
}


extension Authority.Name {
    
    public var localizedString: String {
        switch self {
        case .editCoupons:
            return NSLocalizedString("Edit Coupons", comment: "An authority")
        case .readCoupons:
            return NSLocalizedString("Read Coupons", comment: "An authority")
        case .editAuthorities:
            return NSLocalizedString("Edit Authorities", comment: "An authority")
        case .readAuthorities:
            return NSLocalizedString("Read Authorities", comment: "An authority")
        case .readMechanics:
            return NSLocalizedString("Read Mechanics", comment: "An authority")
        case .editMechanics:
            return NSLocalizedString("Edit Mechanics", comment: "An authority")
        case .editCorporateCoupons:
            return NSLocalizedString("Edit Corporate Car Swaddle Coupon", comment: "An authority")
        default:
            let formatString = NSLocalizedString("Unrecognized Authority: %@", comment: "An authority")
            return String(format: formatString, rawValue)
        }
    }
    
    static let readCoupons = Authority.Name(rawValue: "readCarSwaddleCoupon")
    static let editCoupons = Authority.Name(rawValue: "editCarSwaddleCoupon")
    static let editCorporateCoupons = Authority.Name(rawValue: "editCorporateCarSwaddleCoupon")
    static let readAuthorities = Authority.Name(rawValue: "readAuthorities")
    static let editAuthorities = Authority.Name(rawValue: "editAuthorities")
    static let editMechanics = Authority.Name(rawValue: "editMechanics")
    static let readMechanics = Authority.Name(rawValue: "readMechanics")
    
    
    public func currentUserHasAuthority(in context: NSManagedObjectContext) -> Bool {
        return Authority.currentUser(has: self, in: context)
    }
    
}
