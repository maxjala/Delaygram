//
//  ViewController.swift
//  Delaygram
//
//  Created by Max Jala on 14/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ViewController: UIViewController {
    
    @IBOutlet weak var pictureFeedTableView: UITableView! {
        didSet{
                pictureFeedTableView.delegate = self
                pictureFeedTableView.dataSource = self
    
                pictureFeedTableView.register(picturePostViewCell.cellNib, forCellReuseIdentifier: picturePostViewCell.cellIdentifier)
    }
}
    
    @IBOutlet weak var uploadTabButton: UITabBarItem! {
        didSet{
            //uploadTabButton.addTar
        }
    }
    
    @IBOutlet weak var profileTabButton: UITabBarItem!

    
    
    

    var pictureFeed : [PicturePost] = []
    var filteredPictureFeed: [PicturePost] = []
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    var lastPostID : Int = 0
    
    var followingArray = [String]()
    


    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
        
        fetchFollowingUsersAndPosts()
        listenToFirebase()
        
    }
    
    func listenToFirebase() {
        ref.child("posts").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
        })
        
        // 2. get the snapshot
        ref.child("posts").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            //self.fetchFollowingUsersAndPosts()
            
            // 3. convert snapshot to dictionary
            guard let info = snapshot.value as? NSDictionary else {return}
            // 4. add users to array of following users
            let newPost = self.createPictureFeed(id: snapshot.key, postInfo: info)
            
            if let tempPost = newPost {
                self.pictureFeed.append(tempPost)
                self.addToMyFeed(tempPost)
            }
            
            // sort
            self.pictureFeed.sort(by: { (picture1, picture2) -> Bool in
                return picture1.imagePostID > picture2.imagePostID
                
                //LATER NEED TO CHANGE TO SORT BY POST TIME
            })
            
            // set last message id to last id
            if let lastPost = self.pictureFeed.last {
                self.lastPostID = lastPost.imagePostID
            }
            
            // 5. update table view
            self.pictureFeedTableView.reloadData()
            
        })
        
    }
    
//    func fetchFollowingUsersAndPosts() {
//        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
//            
//            let users = snapshot.value as! [String : String]
//            
//            for each in users {
//                
//                    
//                }
//                
//            }
//            
//
//    })
//    }
    
//    func listenToFire {
//        ref.child("posts").observe(.childAdded, with: { (snapshot) in
//            print("Value : " , snapshot)
//            
//            // 3. convert snapshot to dictionary
//            guard let info = snapshot.value as? NSDictionary else {return}
//            // 4. add users to array of following users
//            
//            self.ref.child("users").child(self.currentUserID).child("following").observe(.value, with: { (SS) in
//                print("Value : " , SS)
//                
//                guard let checkedID = SS.value as? NSDictionary
//                    else {return}
//                
//                let followingArray = checkedID.allValues
//                
//                for each in followingArray {
//                    //self.(id: snapshot.key, postInfo: info)
//                    self.addToPersonalFeed(id: snapshot, postInfo: info)
//                }
//                //self.addToPersonalFeed(id: snapshot.key, postInfo: info)
//                
//                // sort
//                self.pictureFeed.sort(by: { (picture1, picture2) -> Bool in
//                    return picture1.imagePostID > picture2.imagePostID
//                    
//                    //LATER NEED TO CHANGE TO SORT BY POST TIME
//                })
//                
//                // set last message id to last id
//                if let lastPost = self.pictureFeed.last {
//                    self.lastPostID = lastPost.imagePostID
//                }
//                
//                // 5. update table view
//                self.pictureFeedTableView.reloadData()
//        
//        
//    }
    
    func fetchFollowingUsersAndPosts() {
        ref.child("users").child(currentUserID).child("following").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            guard let checkedID = snapshot.value as? NSDictionary
                else {return}
            self.followingArray = (checkedID.allValues as? [String])!
            
            self.pictureFeedTableView.reloadData()
    
        })
        
        ref.child("users").child(currentUserID).child("following").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            guard let checkedID = snapshot.value as? NSDictionary
                else {return}
            self.followingArray = (checkedID.allValues as? [String])!
            
            self.pictureFeedTableView.reloadData()
            
        })
        
        ref.child("users").child(currentUserID).child("following").observe(.childRemoved, with: { (snapshot) in
            print("Value : " , snapshot)
            
            guard let checkedID = snapshot.value as? NSDictionary
                else {return}
            self.followingArray = (checkedID.allValues as? [String])!
            
            self.pictureFeedTableView.reloadData()
            
        })
    }
    
    func addToPersonalFeed(id : Any, postInfo : NSDictionary) {
        
        if let userID = postInfo["userID"] as? String,
            let caption = postInfo["caption"] as? String,
            let profilePictureURL = postInfo["profileImageURL"] as? String,
            let timeStamp = postInfo["timestamp"] as? String,
            let postID = id as? String,
            let currentPostID = Int(postID),
            let postedImageURL =  postInfo["postedImageURL"] as? String,
            let screenName = postInfo["screenName"] as? String {
            
            let newPost = PicturePost(anID: currentPostID, aUserID: userID, aUserScreenName: screenName, aUserProfileImageURL: profilePictureURL, anImagePostURL: postedImageURL, aCaption: caption, aTimeStamp: timeStamp)
            
            for each in self.followingArray {
                if each == newPost.userID {
                    
                    self.pictureFeed.append(newPost)
                    
                    print("")
                }
            }
            //self.pictureFeed.append(newPost)
            
        }
        
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
    

    func addToMyFeed(_ post : PicturePost) {
        
        for each in self.followingArray {
            if each == post.userID {
                
                self.filteredPictureFeed.append(post)
                
            }
        }
        
        
//        for post in self.pictureFeed {
//            for each in self.followingArray {
//            if each == post.userID {
//                
//                self.filteredPictureFeed.append(post)
//        
//            }
//        }
        
        self.pictureFeedTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 

    @IBAction func tempLogoutButton(_ sender: Any) {
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
    

}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPictureFeed.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 550.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: picturePostViewCell.cellIdentifier) as? picturePostViewCell
            else {return UITableViewCell()}
        
        let currentPost = filteredPictureFeed[indexPath.row]
            
            let pictureURL = currentPost.imagePostURL
            let profilePicURL = currentPost.userProfileImageURL

            cell.picturePostImageView.loadImageUsingCacheWithUrlString(urlString: pictureURL)
            cell.profilePicImageView.loadImageUsingCacheWithUrlString(urlString: profilePicURL)
            cell.captionTextView.text = currentPost.caption
            cell.userNameLabel.text = currentPost.userScreenName
        
            cell.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 300)
            
            //cell..text = currentMessage.timestamp
            
            
            
            return cell
        }
    }



