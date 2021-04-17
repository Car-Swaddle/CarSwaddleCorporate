//
//  MechanicListCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/29/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleStore
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
        
        mechanicNameLabel.font = .large
        mechanicEmailLabel.font = .detail
        isMechanicAllowedLabel.font = .detail
        mechanicImageView.layer.cornerRadius = 8
        mechanicImageView.backgroundColor = .neutral2
        
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mechanicImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
    func configure(with mechanic: CarSwaddleStore.Mechanic) {
        let mechanicID = mechanic.identifier
        self.mechanicID = mechanicID
        if let image = profileImageStore.getImage(forMechanicWithID: mechanicID, in: store.mainContext) {
            mechanicImageView.image = image
        } else {
            store.privateContext { [weak self] privateContext in
                self?.mechanicNetwork.getProfileImage(mechanicID: mechanicID, in: privateContext) { [weak self] url, error in
                    guard mechanicID == self?.mechanicID else { return }
                    DispatchQueue.main.async {
                        self?.mechanicImageView.image = profileImageStore.getImage(forMechanicWithID: mechanicID, in: store.mainContext)
                    }
                }
            }
        }
        
        mechanicNameLabel.text = mechanic.user?.displayName
        mechanicEmailLabel.text = mechanic.user?.email
        isMechanicAllowedLabel.text = permissionText(with: mechanic)
        isMechanicAllowedLabel.textColor = permissionColor(with: mechanic)
    }
    
    private func permissionColor(with mechanic: CarSwaddleStore.Mechanic) -> UIColor {
        if mechanic.isAllowed {
            return .green5
        } else {
            return .red5
        }
    }
    
    private func permissionText(with mechanic: CarSwaddleStore.Mechanic) -> String {
        if mechanic.isAllowed {
            return isAllowedText
        } else {
            return isDisallowedText
        }
    }
    
}
