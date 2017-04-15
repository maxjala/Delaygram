//
//  picturePostViewCell.swift
//  Delaygram
//
//  Created by Max Jala on 15/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit

class picturePostViewCell: UITableViewCell {
    
    static let cellIdentifier = "picturePostViewCell"
    static let cellNib = UINib(nibName: picturePostViewCell.cellIdentifier, bundle: Bundle.main)
    
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var picturePostImageView: UIImageView!
    
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    @IBOutlet weak var captionTextView: UITextView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButton(_ sender: Any) {
    }
    
    @IBAction func CommentButton(_ sender: Any) {
    }
    
    @IBAction func viewCommentsButton(_ sender: Any) {
    }
    
    
    
}