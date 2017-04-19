//
//  PersonalProfileViewController.swift
//  Delaygram
//
//  Created by nicholaslee on 18/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import Firebase

class PersonalProfileViewController: UIViewController {

    @IBOutlet weak var displayPictureUser: UIImageView! {
        didSet {
            displayPictureUser.layer.cornerRadius = displayPictureUser.frame.width/2
            displayPictureUser.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var numberOfPosts: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    
    @IBOutlet weak var editButton: UIButton!{
        didSet {
            editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    
    var profileImageURL : String? = ""
    var profileScreenName : String? = ""
    var profileDesc : String? = ""
    
    var profileFollowers : [String]? = []
    var profileFollowing : [String]? = []
    var profilePosts : [String]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
        
        listenToFirebase()
        countingThings()
        }
    
    func listenToFirebase () {
        ref.child("users").child(currentUserID).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            var dict = snapshot.value as? [String : Any]
            
            self.profileScreenName = dict?["screenName"] as? String
            self.profileImageURL = dict?["imageURL"] as? String
            self.profileDesc = dict?["desc"] as? String
            
            print("")
            self.setUpProfile()
            })
        }
    
    func setUpProfile () {
        
        nameLabel.text = profileScreenName
        bioLabel.text = profileDesc
        
        let imageURL = profileImageURL
        displayPictureUser.loadImageUsingCacheWithUrlString(urlString: imageURL!)
        
        
        print("")
    }
    
    func countingThings () {
        ref.child("users").child(currentUserID).child("followers").observe(.value, with: { (snapshot) in
            if (snapshot.value == nil) { return }
            else {
                
                let noOfFollowers = snapshot.value as? NSDictionary
                guard let followers = noOfFollowers?.allValues as? [String]
                    else { return }
                self.profileFollowers = followers
                self.numberOfFollowers.text = String (describing: followers.count)
            }
        })
        
        ref.child("users").child(currentUserID).child("following").observe(.value, with: { (snapshot) in
            if (snapshot.value == nil) { return }
            else {
                
                let noOfFollowing = snapshot.value as? NSDictionary
                guard let following = noOfFollowing?.allValues as? [String]
                    else {return}
                self.profileFollowing = following
                self.numberOfFollowing.text = String (describing: following.count)
            }
        })
        
        ref.child("users").child(currentUserID).child("posts").observe(.value, with: { (snapshot) in
            if (snapshot.value == nil) { return }
            else {
                
                let noOfPost = snapshot.value as? NSDictionary
                guard let post = noOfPost?.allValues as? [String]
                    else {return}
                self.profilePosts = post
                self.numberOfPosts.text = String (describing: post.count)
            }
        })
    }
    
    func editButtonTapped () {
        let controller = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController
        present(controller!, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        
        do {
            try firebaseAuth?.signOut()
            let storyboard = UIStoryboard(name: "LoginStoryBoard", bundle: Bundle.main)
            //logged out and go to the log in page
            let logInVC = storyboard.instantiateViewController(withIdentifier: "AuthNavigationController")
            present(logInVC, animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
//End of PersonalProfileViewController
}

