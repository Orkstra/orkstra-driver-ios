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
        let size: CGFloat = 35.0 // Marker size
        let padding: CGFloat = 10.0 // Add padding to prevent slicing
        let canvasSize = size + padding * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize, height: canvasSize))
        let image = renderer.image { context in
            let rect = CGRect(x: padding, y: padding, width: size, height: size)
            
            // Add shadow
            let shadowColor = UIColor.black.withAlphaComponent(0.3)
            context.cgContext.setShadow(offset: CGSize(width: 1, height: 2), blur: 6.0, color: shadowColor.cgColor)
            shadowColor.setFill()
            context.cgContext.fillEllipse(in: rect) // Shadow is drawn as a blurred ellipse
            
            // Draw the circle
            let circleColor = UIColor.white
            var txtColor = AppColors.trip
            var borderColor = AppColors.trip
            
            if selected {
                borderColor = AppColors.orange
                txtColor = AppColors.orange
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
                .font: UIFont.systemFont(ofSize: 16),
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
        let size: CGFloat = 35.0 // Marker size
        let padding: CGFloat = 10.0 // Add padding to prevent slicing
        let canvasSize = size + padding * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize, height: canvasSize))
        let image = renderer.image { context in
            let rect = CGRect(x: padding, y: padding, width: size, height: size)

            // Add shadow
            let shadowColor = UIColor.black.withAlphaComponent(0.3)
            context.cgContext.setShadow(offset: CGSize(width: 1, height: 2), blur: 6.0, color: shadowColor.cgColor)
            shadowColor.setFill()
            context.cgContext.fillEllipse(in: rect) // Shadow is drawn as a blurred ellipse
            
            // Draw the circle
            let circleColor = UIColor.white
            var txtColor = AppColors.trip
            var borderColor = AppColors.trip
            
            if selected {
                borderColor = AppColors.orange
                txtColor = AppColors.orange
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
        let size: CGFloat = 35.0 // Marker size
        let padding: CGFloat = 10.0 // Add padding to prevent slicing
        let canvasSize = size + padding * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize, height: canvasSize))
        let image = renderer.image { context in
            let rect = CGRect(x: padding, y: padding, width: size, height: size)

            // Add shadow
            let shadowColor = UIColor.black.withAlphaComponent(0.3)
            context.cgContext.setShadow(offset: CGSize(width: 1, height: 2), blur: 6.0, color: shadowColor.cgColor)
            shadowColor.setFill()
            context.cgContext.fillEllipse(in: rect) // Shadow is drawn as a blurred ellipse
            
            // Draw the circle
            var circleColor = AppColors.green
            var borderColor = UIColor.white
            var iconColor = UIColor.black
            if selected {
                circleColor = .white
                borderColor = AppColors.orange
                iconColor = AppColors.orange
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
       
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
        let image = renderer.image { context in
          
            // Draw the white icon in the center
            let iconSize = CGSize(width: 20, height: 20)
            let iconRect = CGRect(
                x: 0,
                y: 0,
                width: iconSize.width,
                height: iconSize.height
            )
            let whiteIcon = icon.withRenderingMode(.alwaysTemplate) // Enable tint color rendering
            AppColors.purple.set() // Set the tint color to white
            whiteIcon.draw(in: iconRect) // Draw the icon respecting tint color
                
        }

        // Create the truck marker
        let truckMarker = GMSMarker()
        truckMarker.icon = image

        return truckMarker
    }
    
}
