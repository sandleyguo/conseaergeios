//
//  SearchBarExtension.swift
//  Conseaerge
//  Copyright © 2019 Sandley Guo. All rights reserved.
//
import UIKit

class SearchBarExtension: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        self.clipsToBounds = false
    }
    
}
