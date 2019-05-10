//
//  SearchBarExtension.swift
//  ConSEAerge
//
//  Created by Sandley Guo on 2/4/19.
//  Copyright © 2019 Sandley Guo. All rights reserved.
//

import UIKit

class SearchBarExtension: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
        //self.layer.borderWidth = 1.5
        //self.layer.borderColor = UIColor(red: 251/255.0, green: 251/255.0, blue: 251/255.0, alpha: 1.0).cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        self.clipsToBounds = false
    }
    
}
