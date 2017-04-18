//
//  PeoplePostViewCell.swift
//  Delaygram
//
//  Created by nicholaslee on 18/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit

class PeoplePostViewCell: UITableViewCell {
    
    
    static let cellIdentifier = "PeoplePostViewCell"
    static let cellNib = UINib(nibName: PeoplePostViewCell.cellIdentifier, bundle: Bundle.main)
    
    
    @IBOutlet weak var peoplePostProfileImage: UIImageView!{
        didSet{
            peoplePostProfileImage.layer.cornerRadius = peoplePostProfileImage.frame.width/2
            peoplePostProfileImage.layer.masksToBounds = true
        }
    
    }
    
    @IBOutlet weak var peoplePostNameLabel: UILabel!
    
    
    @IBOutlet weak var peoplePostImage: UIImageView!
    
    @IBOutlet weak var numberOfLikeLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func likeButtonTap(_ sender: Any) {
    }
    
    @IBAction func commentButtonTap(_ sender: Any) {
    }
    
    @IBAction func viewCommentsTap(_ sender: Any) {
    }
    
    
    
    
    
    
}
