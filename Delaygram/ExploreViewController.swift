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
        
        cell.captionTextView.text = currentPost.caption
        cell.userNameLabel.text = currentPost.userScreenName
        cell.activityIndicator.startAnimating()
        
       // cell.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 300)
        
        
        
        return cell
    }
    
}
