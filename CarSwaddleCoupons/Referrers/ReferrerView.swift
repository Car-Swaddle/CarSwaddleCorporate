//
//  ReferrerView.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 5/14/21.
//  Copyright © 2021 Kyle. All rights reserved.
//

import SwiftUI
import CarSwaddleStore

struct ReferrerItemView: View {
    
    var referrer: Referrer
    var user: User
    
    var body: some View {
        HStack {
            Text(user.displayName)
        }
    }
}

struct ReferrerView_Previews: PreviewProvider {
    
    static var previews: some View {
        let ref = Referrer(context: store.mainContext)
        let user = User(context: store.mainContext)
        ReferrerItemView(referrer: ref, user: user)
    }
}


/*
 
 identifier: String
 // Pseudo-enum for source: user, email, ad, campaign, etc
 sourceType: String
 // Internal metadata - id for ad campaign, email template
 externalID: String
 createdAt: Date
 updatedAt: Date
 referrerDescription: String?
 stripeExpressAccountID: String
 vanityID: String
 activeCouponID: String?
 activePayStructureID: String?
 userID: String
 couponID: String?
 payStructureID: String?
 
 */
