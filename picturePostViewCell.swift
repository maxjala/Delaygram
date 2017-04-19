//
//  picturePostViewCell.swift
//  Delaygram
//
//  Created by Max Jala on 15/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

protocol PicturePostDelegate {
    func goToComments(_ post: PicturePost)
}


class picturePostViewCell: UITableViewCell {
    
    var delegate : PicturePostDelegate? = nil
    
    static let cellIdentifier = "picturePostViewCell"
    static let cellNib = UINib(nibName: picturePostViewCell.cellIdentifier, bundle: Bundle.main)
    
    var ref: FIRDatabaseReference!
    
    
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
        
        ref = FIRDatabase.database().reference()
        // Initialization code
        
    //self.frame = CGRect(x: 0, y: 0, width: 100, height: 10)
   // self.frame = CGRect(
        
        //delegate?.goToComments()
        
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


    @IBAction func likeButton(_ sender: UIButton) {
        if let likeButtonImg = UIImage(named: "heart-empty") {
            sender.setImage(likeButtonImg, for: .normal)
        } else {
        
            let likeButtonImg = UIImage(named: "heart-full")
                sender.setImage(likeButtonImg, for: .normal)
        }

        
        
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
    
    
    
    
    

