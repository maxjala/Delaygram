//
//  testSearchViewController.swift
//  Delaygram
//
//  Created by nicholaslee on 17/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class testSearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var userPost: [PicturePost] = []
    var personalPosts : [PicturePost] = []
    var ref: FIRDatabaseReference!
    var currentUser: FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserId: String = ""
    var lastUserId: Int = 0
    var uploadImageURL : String = ""
    var lastID = 0
    var collectionViewLayout: CustomImageFlowLayout!
    
     
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        if let id = currentUser?.uid{
            print(id)
            currentUserId = id
        }
        collectionViewLayout = CustomImageFlowLayout()
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.backgroundColor = .white
        
        listenToFirebase()
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
    
    
    func listenToFirebase() {
        
        ref.child("posts").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
        })
        
        // 2. get the snapshot
        ref.child("posts").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            // 3. convert snapshot to dictionary
            guard let info = snapshot.value as? NSDictionary else {
            
                return
            }
            // 4. add student to array of messages
            self.addPost(id: snapshot.key, postInfo: info)
            
            // sort
            self.userPost.sort(by: { (post1, post2) -> Bool in
                return post1.imagePostID < post2.imagePostID
                
                //LATER NEED TO CHANGE TO SORT BY POST TIME
            })
            
            // set last message id to last id
            if let lastPost = self.personalPosts.last {
                self.lastID = lastPost.imagePostID
                
            }
            
            // 5. update table view
            self.collectionView.reloadData()
            
        })
        
    }
   
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1//userPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return userPost.count
    }
      // double Check!
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! testCollectionViewCell
        
        let imageName = (indexPath.row % 2 == 0) ? "postedImageURL" : "postedImageURL" // to check
        
        let currentPost = userPost[indexPath.row]
        let userImage = currentPost.imagePostURL
        cell.imageView.image = UIImage(named: imageName)
        cell.imageView.loadImageUsingCacheWithUrlString(urlString: userImage)
        return cell
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

}

