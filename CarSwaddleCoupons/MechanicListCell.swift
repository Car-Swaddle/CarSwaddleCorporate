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


final class MechanicListCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var mechanicEmailLabel: UILabel!
    @IBOutlet private weak var mechanicNameLabel: UILabel!
    @IBOutlet private weak var mechanicImageView: UIImageView!
    
    private var mechanicID: String?
    
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mechanicImageView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
    func configure(with mechanic: Mechanic) {
        let mechanicID = mechanic.identifier
        self.mechanicID = mechanicID
        mechanicNetwork.getProfileImage(mechanicID: mechanicID) { [weak self] url, error in
            guard mechanicID == self?.mechanicID else { return }
            DispatchQueue.main.async {
                self?.mechanicImageView.image = profileImageStore.getImage(forMechanicWithID: mechanicID)
            }
        }
        
        mechanicNameLabel.text = mechanic.user?.displayName
        mechanicEmailLabel.text = mechanic.user?.email
    }
    
}
