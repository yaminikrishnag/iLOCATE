//
//  DesignableUIButton.swift
//  iLocate
//
//  Created by Aparna Shriraksha KN on 10/30/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableUIButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
}
