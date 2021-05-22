//
//  SwiftUIFont.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 5/14/21.
//  Copyright © 2021 Kyle. All rights reserved.
//

import SwiftUI


extension Font {
    
    static func font(type: FontType = .regularFont, size: CGFloat, relativeTo: TextStyle = .body) -> Font {
        return Font.custom(type.rawValue, size: size, relativeTo: relativeTo)
    }
    
    struct FontType {
        
        public var rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static func ==(lhs: FontType, rhs: FontType) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        static let regularFont = FontType(rawValue: "Montserrat-Regular")
        static let extraBold = FontType(rawValue: "Montserrat-ExtraBold")
        static let boldItalic = FontType(rawValue: "Montserrat-BoldItalic")
        static let black = FontType(rawValue: "Montserrat-Black")
        static let medium = FontType(rawValue: "Montserrat-Medium")
        static let bold = FontType(rawValue: "Montserrat-Bold")
        static let light = FontType(rawValue: "Montserrat-Light")
        static let semiBold = FontType(rawValue: "Montserrat-SemiBold")
        static let lightItalic = FontType(rawValue: "Montserrat-LightItalic")
        static let extraLight = FontType(rawValue: "Montserrat-ExtraLight")
        static let extraLightItalic = FontType(rawValue: "Montserrat-ExtraLightItalic")
        static let semiBoldItalic = FontType(rawValue: "Montserrat-SemiBoldItalic")
        static let thinItalic = FontType(rawValue: "Montserrat-ThinItalic")
        static let thin = FontType(rawValue: "Montserrat-Thin")
        static let blackItalic = FontType(rawValue: "Montserrat-BlackItalic")
        static let italic = FontType(rawValue: "Montserrat-Italic")
        static let mediumItalic = FontType(rawValue: "Montserrat-MediumItalic")
        static let extraBoldItalic = FontType(rawValue: "Montserrat-ExtraBoldItalic")
        static let monospaced = FontType(rawValue: "Montserrat-Monospaced")
        
    }
    
}
