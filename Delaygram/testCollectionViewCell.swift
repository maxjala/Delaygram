//
//  testCollectionViewCell.swift
//  Delaygram
//
//  Created by nicholaslee on 17/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit

class testCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
