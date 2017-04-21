//
//  UserRelationViewController.swift
//  Delaygram
//
//  Created by Obiet Panggrahito on 20/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import Firebase

class UserRelationViewController: UIViewController {

    @IBOutlet weak var userRelationTableView: UITableView! {
        didSet {
            userRelationTableView.delegate = self
            userRelationTableView.dataSource = self
            userRelationTableView.register(SearchTableViewCell.cellNib, forCellReuseIdentifier: SearchTableViewCell.cellIdentifier)
        }
    }
    
    var ref: FIRDatabaseReference!
    
    var eitherFollowersOrFollowing : [String] = []
    var imageURL : String? = ""
    var screenName : String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        }
    
//End of UserRelationViewController
}

extension UserRelationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eitherFollowersOrFollowing.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellIdentifier) as? SearchTableViewCell
            else { return UITableViewCell() }
        
        let currentUser = eitherFollowersOrFollowing[indexPath.row]

        ref.child("users").child(currentUser).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            var dict = snapshot.value as? [String : Any]
            
            self.screenName = dict?["screenName"] as? String
            self.imageURL = dict?["imageURL"] as? String
            
        let userImage = self.imageURL
        let selectedUser = self.screenName
        
        cell.userImageView.loadImageUsingCacheWithUrlString(urlString: userImage!)
        cell.userLabel.text = selectedUser
        cell.followButton.isHidden = true
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "PersonalProfileViewController") as? PersonalProfileViewController {
            
            let selectedPerson = eitherFollowersOrFollowing[indexPath.row]
            
            controller.profileType = .otherProfile
            controller.currentUserID = selectedPerson
            navigationController?.pushViewController(controller, animated: true)
        }
    }

}

