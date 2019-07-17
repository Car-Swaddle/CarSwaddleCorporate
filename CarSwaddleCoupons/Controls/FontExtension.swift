//
//  FontExtension.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/1/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import CarSwaddleUI

extension UIFont.FontType {
    
    static let regular: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Regular")
    static let extraBold: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ExtraBold")
    static let boldItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-BoldItalic")
    static let black: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Black")
    static let medium: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Medium")
    static let bold: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Bold")
    static let light: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Light")
    static let semiBold: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-SemiBold")
    static let lightItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-LightItalic")
    static let extraLight: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ExtraLight")
    static let extraLightItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ExtraLightItalic")
    static let semiBoldItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-SemiBoldItalic")
    static let thinItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ThinItalic")
    static let thin: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Thin")
    static let blackItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-BlackItalic")
    static let italic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Italic")
    static let mediumItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-MediumItalic")
    static let extraBoldItalic: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-ExtraBoldItalic")
    static let monoSpaced: UIFont.FontType = UIFont.FontType(rawValue: "Montserrat-Monospaced")
    
}

extension UIFont {
    
    public static let detail: UIFont = UIFont.appFont(type: .regular, size: 14)
    public static let title: UIFont = UIFont.appFont(type: .regular, size: 17)
    public static let large: UIFont = UIFont.appFont(type: .semiBold, size: 19)
    
}

extension UIColor {
    
    public static let largeTextColor: UIColor = .gray6
    public static let titleTextColor: UIColor = .gray6
    public static let detailTextColor: UIColor = .gray4
    public static let errorTextColor: UIColor = .appRed
    
    public static let selectionColor: UIColor = .appBlue
    
}
