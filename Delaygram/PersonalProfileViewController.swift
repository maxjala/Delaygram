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

<<<<<<< HEAD
    @IBOutlet weak var displayPictureUser: UIImageView!
    
    @IBOutlet weak var numberOfPosts: UILabel!
    
    @IBOutlet weak var numberOfFollowers: UILabel!
    
    @IBOutlet weak var numberOfFollowing: UILabel!
    
    @IBOutlet weak var editButton: UIButton!{
        didSet {
            editButton
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    var profileImageURL : String = ""
    var users : [User] = []
=======
    
>>>>>>> c149801f08ec0399b2961e413ee4fbda79b6a295
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
        
        listenToFirebase()
        }

<<<<<<< HEAD
//    func readData () {
//        let userID = FIRAuth.auth()?.currentUser?.uid
//        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            let username = value?["username"] as? Any ?? ""
//            let user = User.init(username: username)
//            
//            // ...
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    }
    
    func listenToFirebase () {
        ref.child("student").observe(.childAdded, with: { (snapshot) in print("Added :" , snapshot)
            
            guard let info = snapshot.value as? NSDictionary
                else {return}
            
            self.addUserToArray(id: snapshot.key, userInfo: info)
        })
    }
    
    func addUserToArray (id:Any, userInfo : NSDictionary) {
        
        if let email = userInfo["email"] as? String,
            let screeenName = userInfo["screenName"] as? String,
            let desc = userInfo["desc"] as? String,
            let imageURL = userInfo["imageURL"] as? String {
            
            let aUser = User(anId: currentUserID, anEmail: email, aScreenName: screeenName, aDesc: desc, anImageURL: imageURL)
            self.users.append(aUser)
        }
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
=======


>>>>>>> c149801f08ec0399b2961e413ee4fbda79b6a295
}





