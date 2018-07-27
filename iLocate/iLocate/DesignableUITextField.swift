//
//  DesignableUITextField.swift
//  iLocate
//
//  Created by Aparna Shriraksha KN on 10/30/17.
//  Copyright © 2017 TeamTwo. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableUITextField: UITextField {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet{
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        if let image = leftImage {
            leftViewMode = .always
            
            let imageView = UIImageView(frame: CGRect(x: leftPadding, y: 0, width: 25, height: 25))
            imageView.image = image
            
            
            var width = leftPadding + 32
            
            if borderStyle == UITextBorderStyle.none || borderStyle == UITextBorderStyle.line{
                width = width + 15
            }
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 32))
            view.addSubview(imageView)
            
            leftView = view
        } else {
            leftViewMode = .never
        }
        
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder! : "", attributes: [NSAttributedStringKey.foregroundColor: tintColor])
        
    }
    
}

