//
//  SocialLoginExtension.swift
//  Conseaerge
//  Copyright © 2019 Sandley Guo. All rights reserved.
//
import UIKit

class SocialLoginExtension: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 25.0
        self.clipsToBounds = true
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor(red: 251/255.0, green: 251/255.0, blue: 251/255.0, alpha: 1.0).cgColor
    }
    
}
