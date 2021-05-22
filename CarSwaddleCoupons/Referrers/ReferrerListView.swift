//
//  ReferrerListView.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 4/17/21.
//  Copyright © 2021 Kyle. All rights reserved.
//

import SwiftUI
import CarSwaddleStore

struct ReferrerListView: View {
    
//    @FetchRequest(
//        entity: Referrer.entity(),
//        sortDescriptors: [
//            NSSortDescriptor(key: \Referrer.createdAt, ascending: true),
//        ],
//        predicate: nil
//    ) var users: FetchedResults<Referrer>
    
    var body: some View {
        Text("Yo wassup")
    }
}





struct ReferrerListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RootView(rootView: ReferrerListView())
        }
    }
}
