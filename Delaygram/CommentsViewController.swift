//
//  CommentsViewController.swift
//  Delaygram
//
//  Created by Max Jala on 19/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var commentsTableView: UITableView! {
        didSet{
            commentsTableView.delegate = self
            commentsTableView.dataSource = self
            
            commentsTableView.register(CommentViewCell.cellNib, forCellReuseIdentifier: CommentViewCell.cellIdentifier)
        }
    }
    
    @IBOutlet weak var inputTextView: UITextView! {
        didSet{
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removePlaceholderText))
            inputTextView.isUserInteractionEnabled = true
            inputTextView.addGestureRecognizer(tapGestureRecognizer)
            
        }
    }
    
    
    var selectedPost : PicturePost?
    var selectedPostID : Int = 0
    
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    var profileScreenName : String = ""
    var profileImageURL : String = ""
    
    var comments : [Comment] = []
    var lastCommentID : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        setCurrentUserAndPostID()
        listenToFirebase()
        
        

        // Do any additional setup after loading the view.
        
        print("hello")
    }
    
    func removePlaceholderText() {
        if inputTextView.text == "Add a comment..." {
            inputTextView.text = ""
            inputTextView.isUserInteractionEnabled = true
//            inputTextView.font = captionTextView.font?.withSize(14)
//            inputTextView.textColor = UIColor.black
        } else {
            return
        }
    }
    
    func setCurrentUserAndPostID() {
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
        
        self.ref.child("users").child(currentUserID).observe(.value, with: { (userSS) in
            print("Value : " , userSS)
            
            let dictionary = userSS.value as? [String: Any]
            
            self.profileScreenName = (dictionary?["screenName"])! as! String
            self.profileImageURL = (dictionary?["imageURL"])! as! String
            
        })
        
        if let postID = selectedPost?.imagePostID {
            selectedPostID = postID
        }
        
    }
    
    func listenToFirebase() {
        // 2. get the snapshot
        ref.child("posts").child("\(selectedPostID)").child("comments").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            // 3. convert snapshot to dictionary
            guard let info = snapshot.value as? NSDictionary else {return}
            // 4. add student to array of messages
            self.addToComments(id: snapshot.key, messageInfo: info)
            
            // sort
            self.comments.sort(by: { (comment1, comment2) -> Bool in
                return comment1.id < comment2.id
            })
            
            // set last message id to last id
            if let lastComment = self.comments.last {
                self.lastCommentID = lastComment.id
            }
            
            // 5. update table view
            self.commentsTableView.reloadData()
            self.tableViewScrollToBottom()
            
        })
        
    }
    
    func addToComments(id : Any, messageInfo : NSDictionary) {

        if let userName = messageInfo["userName"] as? String,
            let body = messageInfo["body"] as? String,
            let imageURL = messageInfo["imageURL"] as? String,
            let commentID = id as? String,
            let timeCreated = messageInfo["timestamp"] as? String,
            let currentCommentID = Int(commentID) {
            
            let newComment = Comment(anId: currentCommentID, aUserName: userName, aBody: body, anImageURL: imageURL, aDate: timeCreated)
            self.comments.append(newComment)
            
        }
        
        
    }
    
    

    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        let currentDate = NSDate()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        let timeCreated = dateFormatter.string(from: currentDate as Date)
        
        if let body = inputTextView.text {
            lastCommentID = lastCommentID + 1
            
            let post : [String : Any] = ["userName": profileScreenName, "body": body, "imageURL" : self.profileImageURL, "timestamp": timeCreated]
            
            ref.child("posts").child("\(selectedPostID)").child("comments").child("\(lastCommentID)").updateChildValues(post)
            
            
            inputTextView.text = ""
        }
        
    }


}

extension CommentsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentViewCell.cellIdentifier) as? CommentViewCell
            else {return UITableViewCell()}
        
        //let currentPost = filteredPictureFeed[indexPath.row]
        //let currentPostUserID = currentPost.userID
        let currentComment = comments[indexPath.row]
        
        cell.labelProfileName.text = currentComment.userName
        cell.imageViewProfile.loadImageUsingCacheWithUrlString(urlString: currentComment.imageURL)
        cell.bodyTextView.text = currentComment.body
        
        
        cell.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 300)
        
        return cell
    }
    
    func tableViewScrollToBottom() {
        let numberOfRows = self.commentsTableView.numberOfRows(inSection: 0)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows - 1, section: 0)
            self.commentsTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    
}
