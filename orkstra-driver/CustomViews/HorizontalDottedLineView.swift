//
//  HorizontalDottedLineView.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 30/04/2025.
//

import UIKit

class HorizontalDottedLineView: UIView {
    
    // Shadow
    @IBInspectable var color: UIColor = UIColor.black
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor // Line color
        shapeLayer.lineWidth = 1 // Line width
        shapeLayer.lineDashPattern = [8, 4] // Dash length and gap length

        // Create a path for the horizontal dotted line
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: rect.midY)) // Start at the left center of the view
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY)) // Move to the right center of the view

        shapeLayer.path = path.cgPath

        // Add the shape layer to the view
        layer.addSublayer(shapeLayer)
    }
}

