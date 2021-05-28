//
//  RootView.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 5/14/21.
//  Copyright © 2021 Kyle. All rights reserved.
//

import SwiftUI

struct RootView<Root: View>: View {
    var rootView: Root
    var body: some View {
        rootView
            .environment(\.font, Font.font(size: 12))
            .environment(\.managedObjectContext, store.mainContext)
    }
}
