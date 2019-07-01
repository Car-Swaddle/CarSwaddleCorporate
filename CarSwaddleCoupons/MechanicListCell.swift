//
//  MechanicListCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/29/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import Store
import CarSwaddleData
import CarSwaddleNetworkRequest
import CarSwaddleUI


private let isAllowedText = NSLocalizedString("Is allowed", comment: "Mechanic is allowed to service")
private let isDisallowedText = NSLocalizedString("Is not allowed", comment: "Mechanic is allowed to service")

final class MechanicListCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var mechanicEmailLabel: UILabel!
    @IBOutlet private weak var mechanicNameLabel: UILabel!
    @IBOutlet private weak var mechanicImageView: UIImageView!
    @IBOutlet private weak var isMechanicAllowedLabel: UILabel!
    
    private var mechanicID: String?
    
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mechanicImageView.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mechanicImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
    func configure(with mechanic: Mechanic) {
        let mechanicID = mechanic.identifier
        self.mechanicID = mechanicID
        if let image = profileImageStore.getImage(forMechanicWithID: mechanicID) {
            mechanicImageView.image = image
        } else {
            mechanicNetwork.getProfileImage(mechanicID: mechanicID) { [weak self] url, error in
                guard mechanicID == self?.mechanicID else { return }
                DispatchQueue.main.async {
                    self?.mechanicImageView.image = profileImageStore.getImage(forMechanicWithID: mechanicID)
                }
            }
        }
        
        mechanicNameLabel.text = mechanic.user?.displayName
        mechanicEmailLabel.text = mechanic.user?.email
        isMechanicAllowedLabel.text = permissionText(with: mechanic)
        isMechanicAllowedLabel.textColor = permissionColor(with: mechanic)
    }
    
    private func permissionColor(with mechanic: Mechanic) -> UIColor {
        if mechanic.isAllowed {
            return .green5
        } else {
            return .red5
        }
    }
    
    private func permissionText(with mechanic: Mechanic) -> String {
        if mechanic.isAllowed {
            return isAllowedText
        } else {
            return isDisallowedText
        }
    }
    
}
