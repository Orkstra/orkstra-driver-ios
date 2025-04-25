//
//  Colors.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 04/04/2025.
//

import UIKit

struct AppColors {
    
    static func accentColor() -> UIColor {
        return UIColor(named: "AccentColor") ?? .blue
    }
    
    static func blueColor() -> UIColor {
        return UIColor(named: "BlueColor") ?? .blue
    }

    static func greenColor() -> UIColor {
        return UIColor(named: "GreenColor") ?? .green
    }
    
    static func orangeColor() -> UIColor {
        return UIColor(named: "OrangeColor") ?? .orange
    }
    
    static func lightOrangeColor() -> UIColor {
        return UIColor(named: "LightOrangeColor") ?? .orange
    }
    
    static func purpleColor() -> UIColor {
        return UIColor(named: "PurpleColor") ?? .purple
    }
    
    static func yellowColor() -> UIColor {
        return UIColor(named: "YellowColor") ?? .purple
    }
    
    static func brownColor() -> UIColor {
        return UIColor(named: "BrownColor") ?? .purple
    }
    
    static func redColor() -> UIColor {
        return UIColor(named: "RedColor") ?? .purple
    }
    
    
    static func turquoiseColor() -> UIColor {
        return UIColor(named: "TurquoiseColor") ?? .purple
    }
    
    static func tripColor() -> UIColor {
        return UIColor(named: "TripColor") ?? .purple
    }
    

    static let accent = accentColor()
    static let blue = blueColor()
    static let green = greenColor()
    static let orange = orangeColor()
    static let lightOrange = lightOrangeColor()
    static let purple = purpleColor()
    static let brown = brownColor()
    static let yellow = yellowColor()
    static let red = redColor()
    static let turquoise = turquoiseColor()
    static let trip = tripColor()
}
