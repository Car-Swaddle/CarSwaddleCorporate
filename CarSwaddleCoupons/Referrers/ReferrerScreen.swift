//
//  ReferrerScreen.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 5/22/21.
//  Copyright © 2021 Kyle. All rights reserved.
//

import SwiftUI

struct ReferrerScreen: View {
    var body: some View {
        NavigationView {
            ReferrerListView()
            .navigationBarTitle(Text("Referrers"))
        }
    }
}

struct ReferrerScreen_Previews: PreviewProvider {
    static var previews: some View {
        ReferrerScreen()
    }
}
