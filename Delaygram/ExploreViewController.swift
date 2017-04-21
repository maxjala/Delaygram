//
//  ExploreViewController.swift
//  Delaygram
//
//  Created by nicholaslee on 18/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ExploreViewController: UIViewController {
    
    var peopleFeed: [PicturePost] = []
    var ref: FIRDatabaseReference!
    var currentPerson: FIRUser? = FIRAuth.auth()?.currentUser
    var currentPersonID: String = ""
    var lastPostID: Int = 0
    
    
    
    
    @IBOutlet weak var peoplePostTableView: UITableView!{
        didSet{
            peoplePostTableView.delegate = self
            peoplePostTableView.dataSource = self
            
            peoplePostTableView.register(PicturePostViewCell.cellNib, forCellReuseIdentifier: PicturePostViewCell.cellIdentifier)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        if let id = currentPerson?.uid {
        print(id)
        currentPersonID = id
        }
        listenToFirebase()
        self.peoplePostTableView.reloadData()
    }
    
    func listenToFirebase(){
        ref.child("posts").observe(.value, with: {(snapshot) in
            print("Value: " , snapshot)
        
        })
        
        ref.child("posts").observe(.childAdded, with:{ (snapshot) in
        
            print("Value: ", snapshot)
            
            guard let info = snapshot.value as? NSDictionary else {return}
            
            self.addToPeopleFeed(id:snapshot.key, postInfo:info)
            
            self.peopleFeed.sort(by:{(picture1, picture2) -> Bool in
                return picture1.imagePostID > picture2.imagePostID
            })
            
            if let lastPost = self.peopleFeed.last {
                self.lastPostID = lastPost.imagePostID
            }
            
            self.peoplePostTableView.reloadData()
            
        })
    }
    
    func addToPeopleFeed(id: Any, postInfo: NSDictionary) {
        if let peopleId = postInfo["userID"] as? String,
            let caption = postInfo["caption"] as? String,
            let peopleProfilePicture = postInfo["profileImageURL"] as? String,
            let timeStamp = postInfo["timestamp"] as? String,
            let postID = id as? String,
            let currentPostId = Int(postID),
            let postedImageURL = postInfo["postedImageURL"] as? String,
            let screenName = postInfo["screenName"] as? String {
            
            let newPeopleFeed = PicturePost(anID: currentPostId, aUserID: peopleId, aUserScreenName: screenName, aUserProfileImageURL: peopleProfilePicture, anImagePostURL: postedImageURL, aCaption: caption, aTimeStamp: timeStamp)
            
            self.peopleFeed.append(newPeopleFeed)
        
        
        }
    }
    
    
    
    
}

extension ExploreViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peopleFeed.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 510.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PicturePostViewCell.cellIdentifier) as? PicturePostViewCell
            else { return UITableViewCell() }
        
        let currentPost = peopleFeed[indexPath.row]
        
            let pictureURL = currentPost.imagePostURL
            let peopleProfilePic = currentPost.userProfileImageURL
        
        
        cell.picturePostImageView.loadImageUsingCacheWithUrlString(urlString: pictureURL)
        cell.profilePicImageView.loadImageUsingCacheWithUrlString(urlString: peopleProfilePic)
        
        cell.captionLabel.text = currentPost.caption
        cell.userNameLabel.text = currentPost.userScreenName
        cell.activityIndicator.startAnimating()
        
        checkifLiked(indexPath: indexPath, sender: cell.likeButton)
        observeForLikes(_post: currentPost, _label: cell.numberOfLikesLabel)
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likedButtonTapped(sender:)), for: .touchUpInside)
        
        cell.delegate = self
        cell.picturePost = currentPost
        
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
        let chosenPostID = "\(self.peopleFeed[buttonRow].imagePostID)"
        let likeButtonImg = UIImage(named: "heart-empty")
        (sender as AnyObject).setImage(likeButtonImg, for: .normal)
        
        
        var hasLiked = false
        
        ref.child("posts").child("\(chosenPostID)").child("likes").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let likers = snapshot.value as? [String : AnyObject] {
                for (ke, value) in likers {
                    if value as! String == self.currentPersonID {
                        hasLiked = true
                        
                        ref.child("posts").child("\(chosenPostID)").child("likes/\(ke)").removeValue()
                        //self.decreaseLikeCount(Int(chosenPostID)!)
                        
                        let likeButtonImg = UIImage(named: "heart-empty")
                        
                        (sender as AnyObject).setImage(likeButtonImg, for: .normal)
                        
                    }
                }
            }
            if !hasLiked {
                let liked = ["likes/\(key)" : self.currentPersonID]
                
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
        let chosenPostID = self.peopleFeed[buttonRow].imagePostID
        
        ref.child("posts").child("\(chosenPostID)").child("likes").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let likesOfPost = snapshot.value as? [String : AnyObject] {
                for (_, value) in likesOfPost {
                    if value as! String == self.currentPersonID {
                        
                        let likeButtonImg = UIImage(named: "heart-full")
                        (sender as AnyObject).setImage(likeButtonImg, for: .normal)
                    }
                }
            }
        })
        ref.removeAllObservers()
        
    }
    
}


extension ExploreViewController : PicturePostDelegate {
    
    func goToComments(_ post: PicturePost) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard .instantiateViewController(withIdentifier: "CommentsViewController") as?
            CommentsViewController else { return }
        controller.selectedPost = post
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
