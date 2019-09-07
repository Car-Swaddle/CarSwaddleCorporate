//
//  AuthorityRequestCell.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/20/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import CarSwaddleData
import CarSwaddleNetworkRequest
import Store

var monthDayYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM dd, yyy"
    return formatter
}()

final class AuthorityRequestCell: UITableViewCell, NibRegisterable {

    @IBOutlet private weak var authorityName: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var requesterImageView: UIImageView!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    
    private var mechanicNetwork: MechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        authorityName.largeStyled()
        nameLabel.titleStyled()
        emailLabel.titleStyled()
        expirationDateLabel.detailStyled()
        
        requesterImageView.layer.cornerRadius = requesterImageView.frame.height/2
        requesterImageView.isHiddenInStackView = true
        
        selectionStyle = .none
    }
    
    func configure(with authorityRequest: AuthorityRequest) {
//        getImage(withUserID: authorityRequest.requesterID) { [weak self] image in
//            guard let self = self else { return }
//            self.requesterImageView.image = image
//        }
        authorityName.text = authorityRequest.authorityName
        nameLabel.text = authorityRequest.requester?.displayName
        emailLabel.text = authorityRequest.requester?.email
        expirationDateLabel.text = monthDayYearFormatter.string(from: authorityRequest.expirationDate)
    }
    
    private func getImage(withUserID userID: String, completion: @escaping (_ image: UIImage?) -> Void) {
        if let image = profileImageStore.getImage(forUserWithID: userID, in: store.mainContext) {
            completion(image)
        }
//        userNetwork.getProfileImage(userID: userID) { imageURL, error in
//        mechanicNetwork.getProfileImage(mechanicID: <#T##String#>, completion: <#T##(URL?, Error?) -> Void#>)
//            DispatchQueue.main.async {
//                completion(profileImageStore.getImage(forUserWithID: userID))
//            }
//        }
    }
    
}
