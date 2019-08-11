//
//  CollectionViewCell.swift
//  CSBC
//
//  Created by Luke Redmore on 2/28/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    

    @IBOutlet var buttonImage: UIImageView!
    @IBOutlet var buttonLabel: UILabel!
    
    func displayContent(image: UIImage, title: String) {
        buttonImage.image = image
        buttonLabel.text = title
    }
    
    
}
