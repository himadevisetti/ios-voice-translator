//
//  CardView.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/28/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit

@IBDesignable class CardView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: CGFloat = 0
    @IBInspectable var shadowOffsetHeight: CGFloat = 5
    @IBInspectable var shadowColor: UIColor = UIColor.black
    @IBInspectable var shadowOpacity: CGFloat = 0.5
    
    override func layoutSubviews() {
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = Float(shadowOpacity)
        
    }
    
}
