//
//  SinglePostViewController.swift
//  Delaygram
//
//  Created by Max Jala on 20/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SinglePostViewController: UIViewController {

    @IBOutlet weak var singlePostTableView: UITableView! {
        didSet{
            singlePostTableView.delegate = self
            singlePostTableView.dataSource = self
            
            singlePostTableView.estimatedRowHeight = 550
            singlePostTableView.rowHeight = UITableViewAutomaticDimension
            singlePostTableView.register(PicturePostViewCell.cellNib, forCellReuseIdentifier: PicturePostViewCell.cellIdentifier)
        }
    }
    
    var selectedPost : PicturePost?
    var aPost : [PicturePost] = []

    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
        
        aPost.append(selectedPost!)
        
        
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
        
        self.singlePostTableView.reloadData()
        
    }



}

extension SinglePostViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aPost.count
    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 550//Choose your custom row height
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PicturePostViewCell.cellIdentifier) as? PicturePostViewCell
            else {return UITableViewCell()}
        
        let currentPost = aPost[indexPath.row]
        //let currentPostUserID = currentPost.userID
        
        let pictureURL = currentPost.imagePostURL
        let profilePicURL = currentPost.userProfileImageURL
        
        cell.delegate = self
        cell.picturePost = currentPost
        
        
        cell.picturePostImageView.loadImageUsingCacheWithUrlString(urlString: pictureURL)
        cell.profilePicImageView.loadImageUsingCacheWithUrlString(urlString: profilePicURL)
        cell.captionTextView.text = currentPost.caption
        cell.userNameLabel.text = currentPost.userScreenName
        //cell.numberOfLikesLabel.text = observeForLike(_post: currentPost)
        checkifLiked(indexPath: indexPath, sender: cell.likeButton)
        observeForLikes(_post: currentPost, _label: cell.numberOfLikesLabel)
        
        //cell.numberOfLikesLabel.text = "\(currentPost.numberOfLikes) likes"
        
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likedButtonTapped(sender:)), for: .touchUpInside)
        
        //increaseLikeCount(currentPost.imagePostID)
        
    
        
        return cell
    }

    func observeForLikes(_post: PicturePost, _label: UILabel) {
        
        let postID = "\(_post.imagePostID)"
        
        ref.child("posts").child(postID).child("likes").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            var numberOfLikes : Int = 0
            var noOfLikesString = "0 likes"
            
            guard let checkedLikes = snapshot.value as? NSDictionary
                else {return}
            
            numberOfLikes = checkedLikes.allValues.count
            
            if numberOfLikes == 1 {
                noOfLikesString = "1 like"
            } else if numberOfLikes > 1 {
                noOfLikesString = "\(numberOfLikes) likes"
            }
            _label.text = noOfLikesString
        })
    }
    
    
    func likedButtonTapped(sender:UIButton) {
        
        let buttonRow = sender.tag
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        let chosenPostID = "\(self.aPost[buttonRow].imagePostID)"
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
        let chosenPostID = self.aPost[buttonRow].imagePostID
        
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

}

extension SinglePostViewController : PicturePostDelegate {
    
    func goToComments(_ post: PicturePost) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard .instantiateViewController(withIdentifier: "CommentsViewController") as?
            CommentsViewController else { return }
        controller.selectedPost = post
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
}
