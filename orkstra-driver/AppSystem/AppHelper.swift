//
//  AppHelper.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 02/04/2025.
//

import Foundation
import UIKit

class AppHelperClass: NSObject {
    
    func formatString(number: Int, decimal: Int = 2) -> String{
        let formatter = NumberFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale  // locale determines the decimal point (. or ,); English locale has "."
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = decimal
        formatter.maximumFractionDigits = decimal
        formatter.numberStyle = .decimal
        let d = NSNumber(value: Double(number)/100)
        let result = formatter.string(from: d)
        return result!
    }
    
    func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }

        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        return topController
    }
    
    func applyGradientToButton(button: UIButton, colors: [CGColor]) {
        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5) // Middle-left
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)   // Middle-right
        
        // Adjust the gradient layer's shape to match the button's corners
        gradientLayer.cornerRadius = button.layer.cornerRadius
        button.layer.masksToBounds = true
        
        // Insert the gradient layer below the button's text and other content
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func assignNibTo(tableView: UITableView?, nibName: String, identifier: String){
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: identifier)
    }
    
    func applyTintColor(to image: UIImage, with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Flip the image vertically to match UIKit's coordinate system
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -image.size.height)

        // Draw the original image as a mask
        let rect = CGRect(origin: .zero, size: image.size)
        context.clip(to: rect, mask: image.cgImage!)
        color.setFill()
        context.fill(rect)

        // Capture the tinted image
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return tintedImage
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return self.filter { seen.insert($0).inserted }
    }
}

extension UIView {
    func addGesture(target: Any, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        self.isUserInteractionEnabled = true // Ensure the view is tappable
        self.addGestureRecognizer(tapGesture)
    }
    
    func addSwipeGesture(target: Any, action: Selector, direction: UISwipeGestureRecognizer.Direction) {
        let swipeGesture = UISwipeGestureRecognizer(target: target, action: action)
        swipeGesture.direction = direction
        self.isUserInteractionEnabled = true // Ensure the view is swipeable
        self.addGestureRecognizer(swipeGesture)
    }
}
