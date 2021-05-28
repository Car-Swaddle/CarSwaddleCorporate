//
//  ReferrerListView.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 4/17/21.
//  Copyright © 2021 Kyle. All rights reserved.
//

import SwiftUI
import CarSwaddleStore

private var userDict: [String:User] = [:]

struct ReferrerListView: View {
    
//    var sortDescriptor: NSSortDescriptor = NSSortDescriptor(keyPath: \Referrer.createdAt, ascending: true)
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: Referrer.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Referrer.createdAt, ascending: true),
        ],
        predicate: nil
    ) var referrers: FetchedResults<Referrer>
    
    private func fetchUser(userID: String) -> User? {
        if let cachedUser = userDict[userID] {
            return cachedUser
        }
        let user = User.fetch(with: userID, in: moc)
        userDict[userID] = user
        return user
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(referrers, id: \.id) { referrer in
                    if let user = fetchUser(userID: referrer.userID) {
                        ReferrerItemView(referrer: referrer, user: user)
                    }
                }
            }
        }
    }
}





struct ReferrerListView_Previews: PreviewProvider {
    
    @Environment(\.managedObjectContext) var context
    
    static var previews: some View {
        return ReferrerListView()
    }
}
