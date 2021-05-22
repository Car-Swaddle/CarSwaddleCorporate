//
//  ReferrerView.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 5/14/21.
//  Copyright © 2021 Kyle. All rights reserved.
//

import SwiftUI
import CarSwaddleStore

struct ReferrerView: View {
    
    var referrer: Referrer
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ReferrerView_Previews: PreviewProvider {
    static var previews: some View {
        let ref = Referrer(context: store.mainContext)
        ReferrerView(referrer: ref)
    }
}
