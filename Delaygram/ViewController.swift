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
            
            pictureFeedTableView.register(PicturePostViewCell.cellNib, forCellReuseIdentifier: PicturePostViewCell.cellIdentifier)
        }
    }
    
    
    @IBOutlet weak var profileTabButton: UITabBarItem!
    
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
        
        fetchFollowingUsers()
        self.pictureFeedTableView.reloadData()
        
    }
    
    func fetchFollowingUsers() {
        
        ref.child("users").child(currentUserID).child("following").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            self.filteredPictureFeed.removeAll()
            
            guard let checkedID = snapshot.value as? NSDictionary
                else {
                    print("observing child value for \(self.currentUserID) following no value")
                    return
            }
            self.followingArray = (checkedID.allValues as? [String])!
            self.followingArray.append(self.currentUserID)
            
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
            self.filteredPictureFeed.sort(by: { (picture1, picture2) -> Bool in
                return picture1.imagePostID > picture2.imagePostID
                
                //LATER NEED TO CHANGE TO SORT BY POST TIME
            })
            
            self.pictureFeedTableView.reloadData()
            
            
        })
        
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
        self.pictureFeedTableView.reloadData()
    }

    
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPictureFeed.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 550//Choose your custom row height
        
        //return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PicturePostViewCell.cellIdentifier) as? PicturePostViewCell
            else {return UITableViewCell()}
        
        let currentPost = filteredPictureFeed[indexPath.row]
        let pictureURL = currentPost.imagePostURL
        let profilePicURL = currentPost.userProfileImageURL
        
        cell.delegate = self
        cell.picturePost = currentPost        
        
        
        cell.picturePostImageView.loadImageUsingCacheWithUrlString(urlString: pictureURL)
        cell.profilePicImageView.loadImageUsingCacheWithUrlString(urlString: profilePicURL)
        cell.captionLabel.text = currentPost.caption
        cell.userNameLabel.text = currentPost.userScreenName
        cell.userNameLabelDisplay.text = currentPost.userScreenName
        //cell.numberOfLikesLabel.text = observeForLike(_post: currentPost)
        checkifLiked(indexPath: indexPath, sender: cell.likeButton)
        observeForLikes(_post: currentPost, _label: cell.numberOfLikesLabel)
        
        //cell.numberOfLikesLabel.text = "\(currentPost.numberOfLikes) likes"
        
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likedButtonTapped(sender:)), for: .touchUpInside)
        
        //increaseLikeCount(currentPost.imagePostID)
        cell.activityIndicator.startAnimating()
        
        
        
        
        return cell
    }
    
    func observeForLikes(_post: PicturePost, _label: UILabel) {
        
        let postID = "\(_post.imagePostID)"
        
        ref.child("posts").child(postID).child("likes").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            var numberOfLikes : [String] = []
            var noOfLikesString = "0 likes"
            
            guard let checkedLikes = snapshot.value as? String
                else {return}
            
            numberOfLikes.append(checkedLikes)
            
            //numberOfLikes = checkedLikes.allValues.
            
            if numberOfLikes.count == 1 {
                noOfLikesString = "1 like"
            } else if numberOfLikes.count > 1 {
                noOfLikesString = "\(numberOfLikes) likes"
            }
            _label.text = noOfLikesString
        })
        
        ref.child("posts").child(postID).child("likes").observe(.childRemoved, with: { (snapshot) in
            print("Value : " , snapshot)
            
            _label.text = self.observeLikeCount(_postID: postID)
        })
        
    }
    
    func observeLikeCount(_postID: String) -> String {
        
        var noOfLikesString = "0 likes"
        
        self.ref.child("posts").child(_postID).child("likes").observe(.value, with: { (ss) in
            
            var numberOfLikes : Int = 0
            
            guard let checkedLikes = ss.value as? NSDictionary
                else {return}
            
            print("CMON")
            
            numberOfLikes = checkedLikes.allValues.count
            
            //numberOfLikes = checkedLikes.allValues.
            
            if numberOfLikes == 1 {
                noOfLikesString = "1 likes"
            } else if numberOfLikes > 1 {
                noOfLikesString = "\(numberOfLikes) likes"
            }
        })
        return noOfLikesString
    }
    
    func likedButtonTapped(sender:UIButton) {
        
        let buttonRow = sender.tag
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        let chosenPostID = "\(self.filteredPictureFeed[buttonRow].imagePostID)"
        let likeButtonImg = UIImage(named: "heart-empty")
        (sender as AnyObject).setImage(likeButtonImg, for: .normal)
        
        
        var hasLiked = false
        
        ref.child("posts").child("\(chosenPostID)").child("likes").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let likers = snapshot.value as? [String : AnyObject] {
                for (ke, value) in likers {
                    if value as! String == self.currentUserID {
                        hasLiked = true

                        ref.child("posts").child("\(chosenPostID)").child("likes/\(ke)").removeValue()
                        //self.decreaseLikeCount(Int(chosenPostID)!)
                        
                        let likeButtonImg = UIImage(named: "heart-empty")
                        
                        (sender as AnyObject).setImage(likeButtonImg, for: .normal)
    
                    }
                }
            }
            if !hasLiked {
                let liked = ["likes/\(key)" : self.currentUserID]
                
                ref.child("posts").child("\(chosenPostID)").updateChildValues(liked)
                //self.increaseLikeCount(Int(chosenPostID)!)
                
                let likeButtonImg = UIImage(named: "heart-full")
                (sender as AnyObject).setImage(likeButtonImg, for: .normal)
            }
        })
        ref.removeAllObservers()
        
    }
    
    
    func checkifLiked(indexPath: IndexPath, sender: UIButton) {
        
        let buttonRow = sender.tag
        let ref = FIRDatabase.database().reference()
        let chosenPostID = self.filteredPictureFeed[buttonRow].imagePostID
        
        ref.child("posts").child("\(chosenPostID)").child("likes").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let likesOfPost = snapshot.value as? [String : AnyObject] {
                for (_, value) in likesOfPost {
                    if value as! String == self.currentUserID {
                        
                        let likeButtonImg = UIImage(named: "heart-full")
                        (sender as AnyObject).setImage(likeButtonImg, for: .normal)
                    }
                }
            }
        })
        ref.removeAllObservers()
        
    }
    
//    func increaseLikeCount(_ postID: Int) {
//        ref.child("posts").child("\(postID)").child("numberOfLikes").observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            guard let noOfLikes = snapshot.value as? Int else {
//                print("print noOfLikes not found. wrong path/observation used")
//                return }
//
//            let newLikesCount = noOfLikes + 1
//            
//            self.ref.child("posts").child("\(postID)").child("numberOfLikes").setValue(newLikesCount)
//            
//        })
//    }
//    
//    func decreaseLikeCount(_ postID: Int) {
//        ref.child("posts").child("\(postID)").child("numberOfLikes").observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            guard let noOfLikes = snapshot.value as? Int else {
//                print("print noOfLikes not found. wrong path/observation used")
//                return }
//
//            let newLikesCount = noOfLikes - 1
//            
//            self.ref.child("posts").child("\(postID)").child("numberOfLikes").setValue(newLikesCount)
//            
//        })
//    }
    
    
    
}




extension ViewController : PicturePostDelegate {
    
    func goToComments(_ post: PicturePost) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard .instantiateViewController(withIdentifier: "CommentsViewController") as?
            CommentsViewController else { return }
        controller.selectedPost = post
        navigationController?.pushViewController(controller, animated: true)
    }
    
    

}



