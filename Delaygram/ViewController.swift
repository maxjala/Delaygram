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
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    var lastPostID : Int = 0
    


    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
        
        let testURL = "https://firebasestorage.googleapis.com/v0/b/delaygram-b862a.appspot.com/o/foodPantry.png?alt=media&token=d33ae4bc-c9f8-457c-9baa-a783b000c57e"
        
//        let testPost = PicturePost(anID: 1, aUserEmail: (currentUser?.email)!, aUserScreenName: (currentUser?.email)!, aUserProfileImageURL: testURL, anImagePostURL: testURL, aCaption: "testing", aTimeStamp: "Now")
//        let testPost = PicturePost(anID: 1, aUserID: currentUserID, aUserScreenName: (currentUser?.email)!, aUserProfileImageURL: testURL, anImagePostURL: testURL, aCaption: "testing", aTimeStamp: "now")
//        
//        self.pictureFeed.append(testPost)
//        
//        let testPost2 = PicturePost(anID: 2, aUserID: currentUserID, aUserScreenName: (currentUser?.email)!, aUserProfileImageURL: testURL, anImagePostURL: testURL, aCaption: "testing", aTimeStamp: "now")
//        
//        self.pictureFeed.append(testPost2)
        
        listenToFirebase()
        
    }
    
    func listenToFirebase() {
        ref.child("posts").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
        })
        
        // 2. get the snapshot
        ref.child("posts").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            // 3. convert snapshot to dictionary
            guard let info = snapshot.value as? NSDictionary else {return}
            // 4. add student to array of messages
            self.addToPersonalFeed(id: snapshot.key, postInfo: info)
            
            // sort
            self.pictureFeed.sort(by: { (picture1, picture2) -> Bool in
                return picture1.imagePostID < picture2.imagePostID
                
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
    
    
//    func addToPersonalFeed(id : Any, postInfo : NSDictionary) {
//        let strTime = "2015-07-27 19:29:50 +0000"
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM-dd HH:mm"
//        formatter.date(from: strTime) // Returns "Jul 27, 2015, 12:29 PM" PST
//        
//
//            if let screenName = postInfo["screenName"] as? String,
//            let caption = postInfo["caption"] as? String,
//            let profilePictureURL = postInfo["profileImageURL"] as? String,
//            let timeStamp = postInfo["timestamp"] as? String,
//            let postID = id as? String, //remember to do postID +=1
//            let userID = ["userID"] as? String,
//            let imagePostURL = ["imagePostURL"] as? String,
//                
//            let strTime = id as? String,
//            let formatter = DateFormatter(),
//            formatter.dateFormat = "MM-dd HH:mm",
//            let currentPostID = formatter {
//
////            let newPost = PicturePost(anID: <#T##Int#>, aUserID: <#T##String#>, aUserScreenName: <#T##String#>, aUserProfileImageURL: <#T##String#>, anImagePostURL: <#T##String#>, aCaption: <#T##String#>, aTimeStamp: <#T##String#>)
//            
//            let newPost = PicturePost(anID: currentPostID, aUserID: userID, aUserScreenName: screenName, aUserProfileImageURL: imagePostURL, anImagePostURL: imagePostURL, aCaption: caption, aTimeStamp: timeStamp)
//                
//                //need to edit this later
//
//            
//        }
//        
//        
//    }
    
    func addToPersonalFeed(id : Any, postInfo : NSDictionary) {
        
                    if let userID = postInfo["userID"] as? String,
                    let caption = postInfo["caption"] as? String,
                    let profilePictureURL = postInfo["profileImageURL"] as? String,
                    let timeStamp = postInfo["timestamp"] as? String,
                    let postID = id as? String, //remember to do postID +=1
                    let currentPostID = Int(postID),
                    let postedImageURL =  postInfo["postedImageURL"] as? String,
                    let screenName = postInfo["screenName"] as? String {
                        
            let newPost = PicturePost(anID: currentPostID, aUserID: userID, aUserScreenName: screenName, aUserProfileImageURL: profilePictureURL, anImagePostURL: postedImageURL, aCaption: caption, aTimeStamp: timeStamp)
                        
                self.pictureFeed.append(newPost)
            
        }
        
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
        return pictureFeed.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 550.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: picturePostViewCell.cellIdentifier) as? picturePostViewCell
            else {return UITableViewCell()}
        
        let currentPost = pictureFeed[indexPath.row]
            
            let pictureURL = currentPost.imagePostURL
            let profilePicURL = currentPost.userProfileImageURL
            //cell.i.loadImageUsingCacheWithUrlString(urlString: messageURL)
            //cell.picturePostImageView.loadImageUsingCacheWithUrlString(urlString: messageURL)
            cell.picturePostImageView.loadImageUsingCacheWithUrlString(urlString: pictureURL)
            cell.profilePicImageView.loadImageUsingCacheWithUrlString(urlString: profilePicURL)
            cell.captionTextView.text = currentPost.caption
            cell.userNameLabel.text = currentPost.userScreenName
        
            cell.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 300)
            
            //cell..text = currentMessage.timestamp
            
            
            
            return cell
        }
    }



