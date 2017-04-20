//
//  PersonalPostCollectionViewCell.swift
//  Delaygram
//
//  Created by Obiet Panggrahito on 19/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit

class PersonalPostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
