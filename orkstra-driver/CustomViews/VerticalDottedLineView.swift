//
//  VerticalDottedLineView.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 30/04/2025.
//

import UIKit

class VerticalDottedLineView: UIView {
    
    //Shadow
    @IBInspectable var color: UIColor = UIColor.black
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor // Line color
        shapeLayer.lineWidth = 1 // Line width
        shapeLayer.lineDashPattern = [8, 4] // Dash length and gap length

        // Create a path for the vertical dotted line
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: 0)) // Start at the top center of the view
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height)) // Move to the bottom center of the view

        shapeLayer.path = path.cgPath

        // Add the shape layer to the view
        layer.addSublayer(shapeLayer)
    }
}
