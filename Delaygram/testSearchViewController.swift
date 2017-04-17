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

class testSearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

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
    
    func addUser(id: Any , postInfo:NSDictionary){
        if let userID = postInfo["userID"] as? String,
            let userScreenName = postInfo["userScreenName"] as? String,
            let caption = postInfo["caption"] as? String,
            let imageURL = postInfo["imageURL"] as? String,
            let postID = id as? String,
            let timeStamp = postInfo["timestamp"] as? String,
            let currentPostID = Int(postID) {
            let newPost = PicturePost(anID: currentPostID, aUserID: userID, aUserScreenName: userScreenName, aUserProfileImageURL: self.uploadImageURL, anImagePostURL: imageURL, aCaption: caption, aTimeStamp: timeStamp)
            
            self.userPost.append(newPost)
        }
    }
    
    func listenToFirebase() {
        ref.child("posts").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
        })
        
        // 2. get the snapshot
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            // 3. convert snapshot to dictionary
            guard let info = snapshot.value as? NSDictionary else {return}
            // 4. add student to array of messages
            self.addUser(id: snapshot.key, postInfo: info)
            
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

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! testCollectionViewCell
        
        let imageName = (indexPath.row % 2 == 0) ? "imageURL" : "imageURL"
        
        let currentUser = userPost[indexPath.row]
        let userImage = currentUser.imagePostURL
        cell.imageView.image = UIImage(named: imageName)
        cell.imageView.loadImageUsingCacheWithUrlString(urlString: userImage)
        return cell
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

}
