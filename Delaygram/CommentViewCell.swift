//
//  UserCell.swift
//  SimpleFirebase
//
//  Created by Max Jala on 12/04/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

class CommentViewCell: UITableViewCell {
    
    static let cellIdentifier = "CommentViewCell"
    static let cellNib = UINib(nibName: CommentViewCell.cellIdentifier, bundle: Bundle.main)
    
    
    @IBOutlet weak var imageViewProfile: UIImageView! {
        didSet{
            imageViewProfile.layer.cornerRadius = imageViewProfile.frame.width/2
            imageViewProfile.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var labelProfileName: UILabel!

    @IBOutlet weak var bodyTextView: UITextView!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


