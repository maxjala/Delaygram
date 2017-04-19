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
        setUpProfile()
        }
    
    func listenToFirebase () {
        ref.child("users").child(currentUserID).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            var dict = snapshot.value as? [String : Any]
            
            self.profileScreenName = dict?["screenName"] as? String
            self.profileImageURL = dict?["imageURL"] as? String
            self.profileDesc = dict?["desc"] as? String
            
            })
            
            ref.child("users").child(currentUserID).child("followers").observe(.value, with: { (snapshot) in
                let value = snapshot.value as? String
                if (value == nil) { return }
                else {
                    self.profileFollowers?.append(value!)
                }
            })
            
            ref.child("users").child(currentUserID).child("following").observe(.value, with: { (snapshot) in
                let value = snapshot.value as? String
                if (value == nil) { return }
                else {
                    self.profileFollowing?.append(value!)
                }
            })
            
            ref.child("users").child(currentUserID).child("posts").observe(.value, with: { (snapshot) in
                let value = snapshot.value as? String
                if (value == nil) { return }
                else {
                    self.profilePosts?.append(value!)
                }
            })
            
            print("")
    }
    
    func setUpProfile () {
        
        nameLabel.text = profileScreenName
        bioLabel.text = profileDesc
        
        //numberOfPosts.text as? Int = profilePosts?.count
//        numberOfFollowers.text = profileFollowers?.count
//        numberOfFollowing.text = profileFollowing?.count
        
        let imageURL = profileImageURL
        displayPictureUser.loadImageUsingCacheWithUrlString(urlString: imageURL!)
        
        
        print("")
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

