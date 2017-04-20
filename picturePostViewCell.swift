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



class PicturePostViewCell: UITableViewCell {
    
    var delegate : PicturePostDelegate? = nil
    
    static let cellIdentifier = "picturePostViewCell"
    static let cellNib = UINib(nibName: PicturePostViewCell.cellIdentifier, bundle: Bundle.main)
    
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
    
    @IBOutlet weak var likeButton: UIButton! {
        didSet{
            let likeButtonImg = UIImage(named: "heart-empty")
            likeButton.setImage(likeButtonImg, for: .normal)
        }
    }
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var viewCommentsButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.activityIndicatorViewStyle = .gray
            activityIndicator.hidesWhenStopped = true
        }
    }
    
    var picturePost : PicturePost?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        ref = FIRDatabase.database().reference()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.stopAnimating()
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
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
    
    
    
    
    

