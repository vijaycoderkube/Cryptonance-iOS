//
//  UiFontExtension.swift
//  Event
//
//  Created by iMac on 01/11/21.
//  Copyright © 2021 CoderKube. All rights reserved.
//

import Foundation
import UIKit

/// Fonts with diffrent styles
enum themeFonts : String {
    case bold = "Poppins-Bold"
    case light = "Poppins-Light"
    case medium = "Poppins-Medium"
    case semiBold = "poppins_semibold"
    case regular = "poppins_regular"
}

/// setting up themeFont through all over the app
/// - Parameters:
///   - size: font size
///   - fontname: font name
/// - Returns: returns UIFont
func themeFont(size : Float,fontname : themeFonts) -> UIFont {
    if UIScreen.main.bounds.width <= 320 {
        return UIFont(name: fontname.rawValue, size: CGFloat(size) - 3.0) ?? UIFont(name: themeFonts.medium.rawValue, size: CGFloat(size) - 3.0)!
    } else if UIScreen.main.bounds.width == 375 {
        return UIFont(name: fontname.rawValue, size: CGFloat(size) - 1.0) ?? UIFont(name: themeFonts.medium.rawValue, size: CGFloat(size) - 1.0)!
    } else {
        return UIFont(name: fontname.rawValue, size: CGFloat(size)) ?? UIFont(name: themeFonts.medium.rawValue, size: CGFloat(size))!
    }
}
