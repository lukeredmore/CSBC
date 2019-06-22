//
//  ResizeableButton.swift
//  CSBC
//
//  Created by Luke Redmore on 2/12/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class ResizableButton: UIButton {
    override var intrinsicContentSize: CGSize {
        return self.titleLabel!.intrinsicContentSize
    }
    
    // Whever the button is changed or needs to layout subviews,
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }
}
