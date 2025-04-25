//
//  Fonts.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 01/04/2025.
//

import UIKit

struct AppFonts {
    
    static func regular(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func bold(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    static let titleFont = regular(size: 24)
    static let subtitleFont = regular(size: 18)
    static let bodyFont = regular(size: 14)
}
