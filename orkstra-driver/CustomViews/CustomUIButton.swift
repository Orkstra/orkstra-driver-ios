//
//  CustomUIButton.swift
//  orkstra-driver
//
//  Created by Karim Maurice on 04/04/2025.
//

import UIKit

class CustomUiButton: UIButton {

    //Shadow
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.updateView()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor(red: 0.826, green: 0.826, blue: 0.826, alpha: 1) {
        didSet {
            self.updateView()
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.3 {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 5 {
        didSet {
            self.updateView()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 7 {
        didSet {
            self.updateView()
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.updateView()
        }
    }
    
    func setBoldTitle(string: String, color: UIColor){
        let boldFont = UIFont.boldSystemFont(ofSize: 17)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: color
        ]
        let attributedTitle = NSAttributedString(string: string, attributes: attributes)
        self.setAttributedTitle(attributedTitle, for: .normal)
    }

    //Apply params
    func updateView() {
        self.layer.shadowColor = self.shadowColor.cgColor
        self.layer.shadowOpacity = self.shadowOpacity
        self.layer.shadowOffset = self.shadowOffset
        self.layer.shadowRadius = self.shadowRadius
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
    }

}
