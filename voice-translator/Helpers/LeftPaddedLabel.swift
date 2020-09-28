//
//  LeftPaddedLabel.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/26/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit

class LeftPaddedLabel: UILabel{
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        clipsToBounds = true
        
//        layer.addBorder(edge: .top, color: .black, thickness: 1)
//        layer.addBorder(edge: .bottom, color: .black, thickness: 1)
//        layer.addBorder(edge: .right, color: .black, thickness: 1)
//        layer.addBorder(edge: .left, color: .white, thickness: 0)
//
//        layer.cornerRadius = 5
//        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
//        layer.masksToBounds = true
//        clipsToBounds = true

    }
}

extension CALayer {

    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: -1, y: 0, width: self.frame.width + 1, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: -1, y: self.frame.height - thickness, width: self.frame.width + 1, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }

        border.backgroundColor = color.cgColor

        self.addSublayer(border)
    }

}
