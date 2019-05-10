//
//  ButtonGradientExtension.swift
//  Conseaerge
//  Copyright © 2019 Sandley Guo. All rights reserved.
//
import UIKit

class ButtonGradientExtension: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 30.0
        self.clipsToBounds = true
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor(red: 251/255.0, green: 251/255.0, blue: 251/255.0, alpha: 1.0).cgColor
        
        self.setGradientBackground(colorOne: UIColor(red: 86/255, green: 171/255, blue: 212/255, alpha: 1.0), colorTwo: UIColor(red: 104/255, green: 212/255, blue: 249/255, alpha: 1.0))
    }
}

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

