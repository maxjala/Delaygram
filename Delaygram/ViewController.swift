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
        
        var testURL = "https://firebasestorage.googleapis.com/v0/b/delaygram-b862a.appspot.com/o/foodPantry.png?alt=media&token=d33ae4bc-c9f8-457c-9baa-a783b000c57e"
        
        var testPost = PicturePost(anID: 1, aUserEmail: (currentUser?.email)!, aUserScreenName: (currentUser?.email)!, aUserProfileImageURL: testURL, anImagePostURL: testURL, aCaption: "testing", aTimeStamp: "Now")
        
        self.pictureFeed.append(testPost)
        
    }
    
    func listenToFirebase() {
        ref.child("posts").child(currentUserID).child("subscribedPosts").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
        })
        
        // 2. get the snapshot
        ref.child("posts").child(currentUserID).child("subscribedPosts").observe(.childAdded, with: { (snapshot) in
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
        
//        ref.child("chat").child(currentChat.id).child("messages").observe(.childRemoved, with: { (snapshot) in
//            print("Value : " , snapshot)
//            
//            guard let deletedId = Int(snapshot.key)
//                else {return}
//            
//            if let deletedIndex = self.messages.index(where: { (msg) -> Bool in
//                return msg.id == deletedId
//            }) {
//                self.messages.remove(at: deletedIndex)
//                let indexPath = IndexPath(row: deletedIndex, section: 0)
//                self.chatTableView.deleteRows(at: [indexPath], with: .right)
//            }
//            
//            // to delete :
//            //            self.ref.child("path").removeValue()
//            //            self.ref.child("student").child("targetId").removeValue()
//        })
        
        
    }
    
    func addToPersonalFeed(id : Any, postInfo : NSDictionary) {
        
        if let email = postInfo["email"] as? String,
            let screenName = postInfo["screenName"] as? String,
            let caption = postInfo["caption"] as? String,
            let profilePictureURL = postInfo["profileImageURL"] as? String,
            let timeStamp = postInfo["timestamp"] as? String,
            let postID = id as? String, //remember to do postID +=1
            let imagePostURL = ["imagePostURL"] as? String,
            let currentPostID = Int(postID) {
            let newPost = PicturePost(anID: currentPostID, aUserEmail: email, aUserScreenName: screenName, aUserProfileImageURL: profilePictureURL, anImagePostURL: imagePostURL, aCaption: caption, aTimeStamp: timeStamp)

            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictureFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: picturePostViewCell.cellIdentifier) as? picturePostViewCell
            else {return UITableViewCell()}
        
        let currentPost = pictureFeed[indexPath.row]
            
            let pictureURL = currentPost.imagePostURL
            //cell.i.loadImageUsingCacheWithUrlString(urlString: messageURL)
            //cell.picturePostImageView.loadImageUsingCacheWithUrlString(urlString: messageURL)
            cell.picturePostImageView.loadImageUsingCacheWithUrlString(urlString: pictureURL)
            cell.profilePicImageView.loadImageUsingCacheWithUrlString(urlString: pictureURL)
            cell.captionTextView.text = currentPost.caption
            cell.userNameLabel.text = currentPost.userScreenName
            
            //cell..text = currentMessage.timestamp
            
            
            
            return cell
        }
    }

//Loading Pictures

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        // Check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage as? UIImage
            return
        }
        
        // Otherwise fire off a new download
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: url as! URL, completionHandler: { (data, response, error) in
            
            // Dowload hit an error so let's return out
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            })
        }).resume()
    }
    
    
    
}

