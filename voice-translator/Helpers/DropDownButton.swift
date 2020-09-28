//
//  DropDownButton.swift
//  voice-translator
//
//  Created by Hima Devisetti on 9/25/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import UIKit

class DropDownButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: bounds.width - 30, bottom: 0, right: 0)
        
//      semanticContentAttribute = .forceRightToLeft
    }
}
