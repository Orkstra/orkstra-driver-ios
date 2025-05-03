//
//  MarkersClass.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 03/04/2025.
//

import UIKit
import GoogleMaps

class MarkerManager: NSObject{
    
    func createStopMarker(stop: Stop?, selected: Bool = false) -> UIImage {
        let number = stop?.order ?? 0
        let size: CGFloat = 40.0 // Marker size
        let padding: CGFloat = 10.0 // Add padding to prevent slicing
        let canvasSize = size + padding * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize, height: canvasSize))
        let image = renderer.image { context in
            let rect = CGRect(x: padding, y: padding, width: size, height: size)
            
            // Add shadow
            let shadowColor = UIColor.black.withAlphaComponent(0.3)
            context.cgContext.setShadow(offset: CGSize(width: 1, height: 2), blur: 4.0, color: shadowColor.cgColor)
            shadowColor.setFill()
            context.cgContext.fillEllipse(in: rect) // Shadow is drawn as a blurred ellipse
            
            // Draw the circle
            let circleColor = UIColor.white
            var txtColor = AppColors.trip
            var borderColor = AppColors.trip
            
            if selected {
                borderColor = AppColors.purple
                txtColor = AppColors.purple
            }
            
            circleColor.setFill()
            context.cgContext.fillEllipse(in: rect)

            // Draw the border
            borderColor.setStroke()
            context.cgContext.setLineWidth(2.0)
            context.cgContext.strokeEllipse(in: rect)

            // Draw the number in the center
            let numberText = "\(number)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: txtColor
            ]
            let textSize = numberText.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (renderer.format.bounds.width - textSize.width) / 2,
                y: (renderer.format.bounds.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            numberText.draw(in: textRect, withAttributes: attributes)
        }
        return image
    }
    
    func createDeliveredMarker(with icon: UIImage, selected: Bool = false) -> UIImage {
        let size: CGFloat = 40.0 // Marker size
        let padding: CGFloat = 10.0 // Add padding to prevent slicing
        let canvasSize = size + padding * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize, height: canvasSize))
        let image = renderer.image { context in
            let rect = CGRect(x: padding, y: padding, width: size, height: size)

            // Add shadow
            let shadowColor = UIColor.black.withAlphaComponent(0.3)
            context.cgContext.setShadow(offset: CGSize(width: 1, height: 2), blur: 4.0, color: shadowColor.cgColor)
            shadowColor.setFill()
            context.cgContext.fillEllipse(in: rect) // Shadow is drawn as a blurred ellipse
            
            // Draw the circle
            let circleColor = UIColor.white
            var txtColor = AppColors.trip
            var borderColor = AppColors.trip
            
            if selected {
                borderColor = AppColors.purple
                txtColor = AppColors.purple
            }
            
            circleColor.setFill()
            context.cgContext.fillEllipse(in: rect)

            // Draw the white border
            borderColor.setStroke()
            context.cgContext.setLineWidth(2.0)
            context.cgContext.strokeEllipse(in: rect)

            // Draw the white icon in the center
            let iconSize = CGSize(width: size * 0.45, height: size * 0.35) // Icon size is 50% of the marker size
            let iconRect = CGRect(
                x: (canvasSize - iconSize.width) / 2,
                y: (canvasSize - iconSize.height) / 2,
                width: iconSize.width,
                height: iconSize.height
            )
            let whiteIcon = icon.withRenderingMode(.alwaysTemplate) // Enable tint color rendering
            txtColor.set()
            whiteIcon.draw(in: iconRect) // Draw the icon respecting tint color
                
        }
        return image
    }
    
    func createHomeMarker(with icon: UIImage, selected: Bool = false) -> UIImage {
        let size: CGFloat = 40.0 // Marker size
        let padding: CGFloat = 10.0 // Add padding to prevent slicing
        let canvasSize = size + padding * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize, height: canvasSize))
        let image = renderer.image { context in
            let rect = CGRect(x: padding, y: padding, width: size, height: size)

            // Add shadow
            let shadowColor = UIColor.black.withAlphaComponent(0.3)
            context.cgContext.setShadow(offset: CGSize(width: 1, height: 2), blur: 4.0, color: shadowColor.cgColor)
            shadowColor.setFill()
            context.cgContext.fillEllipse(in: rect) // Shadow is drawn as a blurred ellipse
            
            // Draw the circle
            var circleColor = AppColors.neonGreen
            var borderColor = UIColor.white
            var iconColor = UIColor.black
            if selected {
                circleColor = .white
                borderColor = AppColors.purple
                iconColor = AppColors.purple
            }
            
            circleColor.setFill()
            context.cgContext.fillEllipse(in: rect)

            // Draw the white border
            borderColor.setStroke()
            context.cgContext.setLineWidth(2.0)
            context.cgContext.strokeEllipse(in: rect)

            // Draw the white icon in the center
            let iconSize = CGSize(width: size * 0.5, height: size * 0.5) // Icon size is 50% of the marker size
            let iconRect = CGRect(
                x: (canvasSize - iconSize.width) / 2,
                y: (canvasSize - iconSize.height) / 2,
                width: iconSize.width,
                height: iconSize.height
            )
            let whiteIcon = icon.withRenderingMode(.alwaysTemplate) // Enable tint color rendering
            iconColor.set() // Set the tint color to white
            whiteIcon.draw(in: iconRect) // Draw the icon respecting tint color
                
        }
        return image
    }
    
    func createTruckMarker(with icon: UIImage) -> GMSMarker {
       
        let size: CGFloat = 30.0 // Marker size
        let padding: CGFloat = 10.0 // Add padding to prevent slicing
        let canvasSize = size + padding * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize, height: canvasSize))
        let image = renderer.image { context in
            let rect = CGRect(x: padding, y: padding, width: size, height: size)

            // Add shadow
            let shadowColor = UIColor.black.withAlphaComponent(0.2)
            context.cgContext.setShadow(offset: CGSize(width: 0, height: 0), blur: 4.0, color: shadowColor.cgColor)
            shadowColor.setFill()
            context.cgContext.fillEllipse(in: rect) // Shadow is drawn as a blurred ellipse
            
            // Draw the circle
            let circleColor = AppColors.purple
            let borderColor = UIColor.white
            let iconColor = UIColor.white
            
            circleColor.setFill()
            context.cgContext.fillEllipse(in: rect)

            // Draw the white border
            borderColor.setStroke()
            context.cgContext.setLineWidth(1.5)
            context.cgContext.strokeEllipse(in: rect)

            // Draw the white icon in the center
            let iconSize = CGSize(width: size * 0.6, height: size * 0.5) // Icon size is 50% of the marker size
            let iconRect = CGRect(
                x: (canvasSize - iconSize.width) / 2,
                y: (canvasSize - iconSize.height) / 2,
                width: iconSize.width,
                height: iconSize.height
            )
            let whiteIcon = icon.withRenderingMode(.alwaysTemplate) // Enable tint color rendering
            iconColor.set() // Set the tint color to white
            whiteIcon.draw(in: iconRect) // Draw the icon respecting tint color
                
        }
        

        // Create the truck marker
        let truckMarker = GMSMarker()
        truckMarker.icon = image
        truckMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5) // Align center-bottom of the marker to its position
        return truckMarker
    }
    
    func setupFlashlightMarker(at position: CLLocationCoordinate2D) -> GMSMarker {
        let appHelper = AppHelperClass()
        
        let flashlightImage = UIImage(named: "flashlight")
        let resizedFlashlightImage = appHelper.resizeImage(image: flashlightImage!, targetSize: CGSize(width: 40, height: 35))

        // Apply the tint color to the resized image
        let tintedFlashlightImage = appHelper.applyTintColor(to: resizedFlashlightImage, with: AppColors.purple)
        
        // Create the flashlight marker
        let flashlightMarker = GMSMarker()
        flashlightMarker.position = position
        flashlightMarker.icon = tintedFlashlightImage // Set the tinted image
        flashlightMarker.groundAnchor = CGPoint(x: 0.5, y: 1) // Base of the flashlight at the position
        flashlightMarker.zIndex = -1
        
        return flashlightMarker
    }

}
