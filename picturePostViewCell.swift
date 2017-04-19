//
//  picturePostViewCell.swift
//  Delaygram
//
//  Created by Max Jala on 15/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit

protocol PicturePostDelegate {
    func goToComments(_ post: PicturePost)
}


class picturePostViewCell: UITableViewCell {
    
    var delegate : PicturePostDelegate? = nil
    
    static let cellIdentifier = "picturePostViewCell"
    static let cellNib = UINib(nibName: picturePostViewCell.cellIdentifier, bundle: Bundle.main)
    
    
    @IBOutlet weak var profilePicImageView: UIImageView! {
        didSet{
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.width/2
        profilePicImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var picturePostImageView: UIImageView!
    
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var viewCommentsButton: UIButton!

    var picturePost : PicturePost?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    //self.frame = CGRect(x: 0, y: 0, width: 100, height: 10)
   // self.frame = CGRect(
        
        //delegate?.goToComments()
        
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButton(_ sender: Any) {
        
        
    }
    
    @IBAction func CommentButton(_ sender: Any) {
        if delegate != nil {
            if let _picturePost = picturePost {
                delegate?.goToComments(_picturePost)
            }
        }
        
    }
    
    @IBAction func viewCommentsButton(_ sender: Any) {
        if delegate != nil {
            if let _picturePost = picturePost {
                delegate?.goToComments(_picturePost)
            }
        }
    }
    
    
    
    
    
}
