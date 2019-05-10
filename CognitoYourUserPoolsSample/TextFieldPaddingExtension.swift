///
//  TextFieldPaddingExtension.swift
//  Conseaerge
//  Copyright © 2019 Sandley Guo. All rights reserved.
//
import UIKit

class TextFieldPaddingExtension: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.borderStyle = UITextField.BorderStyle.roundedRect
    }
}
