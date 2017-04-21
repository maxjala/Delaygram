//
//  PersonalProfileViewController.swift
//  Delaygram
//
//  Created by nicholaslee on 18/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import Firebase

enum ProfileType {
    case myProfile
    case otherProfile
}

class PersonalProfileViewController: UIViewController {

    @IBOutlet weak var displayPictureUser: UIImageView! {
        didSet {
            displayPictureUser.layer.cornerRadius = displayPictureUser.frame.width/2
            displayPictureUser.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var numberOfPosts: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(numberOfFollowersTapped))
            numberOfFollowers.addGestureRecognizer(tap)
            numberOfFollowers.isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var numberOfFollowing: UILabel! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(numberOfFollowingTapped))
            numberOfFollowing.addGestureRecognizer(tap)
            numberOfFollowing.isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!

    @IBOutlet weak var postsCollectionView: UICollectionView! {
        didSet {
            postsCollectionView.delegate = self
            postsCollectionView.dataSource = self
        }
    }
    
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    
    var profileType : ProfileType = .myProfile
    var selectedProfile : User?
    
    var profileImageURL : String? = ""
    var profileScreenName : String? = ""
    var profileDesc : String? = ""
    
    var profileFollowers : [String]? = []
    var profileFollowing : [String]? = []
    var profilePosts : [String]? = []
    
    var collectionViewLayout: CustomImageFlowLayout!
    var userPost: [PicturePost] = []
    var personalPosts : [PicturePost] = []
    var lastID = 0
    
    var postReferences = [String]()
    var onlyMyPosts : [PicturePost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        configuringProfileType(profileType)
        
        //collectionView setting
        collectionViewLayout = CustomImageFlowLayout()
        postsCollectionView.collectionViewLayout = collectionViewLayout
        postsCollectionView.backgroundColor = .white
        
        setupProfile()
        //setupCollectionView()
        
        fetchPersonalPostIDs()
        }
    
    func configuringProfileType (_ type : ProfileType) {
        switch type {
        case .myProfile :
            
            configureMyProfile()
        case .otherProfile:
            
            configureOtherProfile()
        }
    }
    
    func configureMyProfile () {
        
        let barButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = barButtonItem
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
    }
    
    func configureOtherProfile () {
        
        editButton.setTitle("Follow", for: .normal)
        checkFollowing(sender: editButton)
        editButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }
    
    func setupProfile () {
        
        
        ref.child("users").child(currentUserID).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            var dict = snapshot.value as? [String : Any]
            
            self.profileScreenName = dict?["screenName"] as? String
            self.profileImageURL = dict?["imageURL"] as? String
            self.profileDesc = dict?["desc"] as? String
            
            self.nameLabel.text = self.profileScreenName
            self.bioLabel.text = self.profileDesc
            
            let imageURL = self.profileImageURL
            self.displayPictureUser.loadImageUsingCacheWithUrlString(urlString: imageURL!)
            })
        
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
                
                self.numberOfPosts.text = String("\(snapshot.childrenCount)")
            }
        })
    }
    
    func fetchPersonalPostIDs() {
        
        ref.child("users").child(currentUserID).child("posts").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            self.onlyMyPosts.removeAll()
            
            guard let checkedID = snapshot.value as? NSDictionary
                else {
                    print("observing child value for \(self.currentUserID) following no value")
                    return
            }
            self.postReferences = (checkedID.allKeys as? [String])!
            
            self.fetchPosts()
            
        })
        
    }
    
    
    func fetchPosts() {
        
        ref.child("posts").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            // 3. convert snapshot to dictionary
            guard let info = snapshot.value as? NSDictionary else {return}
            // 4. add users to array of following users
            let newPost = self.createPictureFeed(id: snapshot.key, postInfo: info)
            
            if let tempPost = newPost {
                self.addToMyFeed(tempPost)
            }
            
            // sort
            self.onlyMyPosts.sort(by: { (picture1, picture2) -> Bool in
                return picture1.imagePostID > picture2.imagePostID
                
                //LATER NEED TO CHANGE TO SORT BY POST TIME
            })
            
            //self.postsCollectionView.reloadData()
            
            
        })
        
    }
    
    func addToMyFeed(_ post : PicturePost) {
        
        for each in self.postReferences {
            if Int(each) == post.imagePostID {
                
                self.onlyMyPosts.append(post)
                
            }
        }
        self.postsCollectionView.reloadData()
    }
    
    
    
    func createPictureFeed(id : Any, postInfo : NSDictionary) -> PicturePost?{
        
        if let userID = postInfo["userID"] as? String,
            let caption = postInfo["caption"] as? String,
            let profilePictureURL = postInfo["profileImageURL"] as? String,
            let timeStamp = postInfo["timestamp"] as? String,
            let postID = id as? String,
            let currentPostID = Int(postID),
            let postedImageURL =  postInfo["postedImageURL"] as? String,
            let screenName = postInfo["screenName"] as? String {
            
            let newPost = PicturePost(anID: currentPostID, aUserID: userID, aUserScreenName: screenName, aUserProfileImageURL: profilePictureURL, anImagePostURL: postedImageURL, aCaption: caption, aTimeStamp: timeStamp)
            
            return newPost
            
        }
        return nil
    }
    
    
    
    func addPost(id: Any , postInfo:NSDictionary){
        if let userID = postInfo["userID"] as? String,
            let caption = postInfo["caption"] as? String,
            let profilePictureURL = postInfo["profileImageURL"] as? String,
            let timeStamp = postInfo["timestamp"] as? String,
            let postID = id as? String,
            let currentPostID = Int(postID),
            let postedImageURL =  postInfo["postedImageURL"] as? String,
            let screenName = postInfo["screenName"] as? String {
            
            let newPost = PicturePost(anID: currentPostID, aUserID: userID, aUserScreenName: screenName, aUserProfileImageURL: profilePictureURL, anImagePostURL: postedImageURL, aCaption: caption, aTimeStamp: timeStamp)
            
            self.userPost.append(newPost)
        }
    }
    
    func editButtonTapped () {
        let controller = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController
        present(controller!, animated: true, completion: nil)
    }
    
    func checkFollowing (sender : UIButton) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (_, value) in following {
                    if value as! String == self.currentUserID {
                        
                        (sender as AnyObject).setTitle("Following", for: .normal)
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func followButtonTapped (sender : UIButton) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (ke, value) in following {
                    if value as! String == self.currentUserID {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.currentUserID).child("followers/\(ke)").removeValue()
                        
                        (sender as AnyObject).setTitle("Follow", for: .normal)
                        
                        
                    }
                }
            }
            if !isFollower {
                let following = ["following/\(key)" : self.currentUserID]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.currentUserID).updateChildValues(followers)
                
                (sender as AnyObject).setTitle("Following", for: .normal)
            }
        })
        ref.removeAllObservers()
    }
    
    func logoutButtonTapped() {
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
    
    func numberOfFollowersTapped () {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "UserRelationViewController") as! UserRelationViewController
        
            guard let followers : [String] = profileFollowers
                else {return}
        
        controller.eitherFollowersOrFollowing = followers
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func numberOfFollowingTapped () {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "UserRelationViewController") as! UserRelationViewController
        
            guard let following : [String] = profileFollowing
                else {return}
        
        controller.eitherFollowersOrFollowing = following
        navigationController?.pushViewController(controller, animated: true)
    }

//End of PersonalProfileViewController
}

extension PersonalProfileViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return userPost.count
        return onlyMyPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! PersonalPostCollectionViewCell
        
//        let imageName = (indexPath.row % 2 == 0) ? "postedImageURL" : "postedImageURL" // kand hui said we don't need this
        
//        let currentPost = userPost[indexPath.row]
//        let userImage = currentPost.imagePostURL
//        cell.imageView.image = UIImage(named: imageName)    //kang hui said we don't need this
//        cell.imageView.loadImageUsingCacheWithUrlString(urlString: userImage)
        
        let currentPost = onlyMyPosts[indexPath.row]
        let userImage = currentPost.imagePostURL
        cell.imageView.loadImageUsingCacheWithUrlString(urlString: userImage)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentPost = onlyMyPosts[indexPath.row]
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "SinglePostViewController") as? SinglePostViewController
        
        controller?.selectedPost = currentPost
        
        navigationController?.pushViewController(controller!, animated: true)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}



