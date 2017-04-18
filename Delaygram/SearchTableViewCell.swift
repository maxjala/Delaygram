//
//  SearchTableViewCell.swift
//  Delaygram
//
//  Created by nicholaslee on 17/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView! {
        didSet{
            userImageView.layer.cornerRadius = userImageView.frame.width/2
            userImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    
    
    
    
    static let cellIdentifier = "SearchTableViewCell"
    static let cellNib = UINib(nibName: SearchTableViewCell.cellIdentifier, bundle: Bundle.main)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
