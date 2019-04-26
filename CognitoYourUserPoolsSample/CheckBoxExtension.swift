//
//  CheckBoxExtension.swift
//  ConSEAerge
//
//  Created by Sandley Guo on 12/17/18.
//  Copyright © 2018 Sandley Guo. All rights reserved.
//

import UIKit

class CheckBoxExtension: UIButton {
    
    let checkedImage = UIImage(named: "Checked Symbol") //as! UIImage
    let uncheckedImage = UIImage(named: "Unchecked Symbol") //as! UIImage
    
    var isChecked:Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
            }
            else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(rememberMe(sender:)), for: .touchUpInside)
        self.isChecked = false
        buttonState = false
    }
    
    @objc func rememberMe(sender: UIButton) {
        if (sender == self) {
            if isChecked == true {
                isChecked = false
                buttonState = false
            }
            else {
                isChecked = true
                buttonState = true
            }
        }
    }
}
