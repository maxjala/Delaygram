//
//  SearchViewController.swift
//  Delaygram
//
//  Created by nicholaslee on 16/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SearchViewController: UIViewController {

    @IBOutlet weak var userTableView: UITableView! {
        didSet{
            userTableView.delegate = self
            userTableView.dataSource = self
            
            userTableView.register(SearchTableViewCell.cellNib, forCellReuseIdentifier: SearchTableViewCell.cellIdentifier)
        
        }
    
    }
    
    
    @IBOutlet weak var userSearchBar: UISearchBar!
    
    var searchUser: [User] = []
    var ref: FIRDatabaseReference!
    var currentUser: FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserId: String = ""
    var lastUserId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        
        if let id = currentUser?.uid{
            print(id)
            currentUserId = id
            
            listenToFirebase()
        }
    }
    
    func addUser(id: Any , userInfo:NSDictionary){
        if let userName = userInfo["screenName"] as? String,
        let userImage = userInfo["imageURL"] as? String,
            let userId = id as? String,
            let userEmail = userInfo["email"] as? String,
            let userDescription = userInfo["desc"] as? String{
            
        let newUser = User(anId: userId, anEmail: userEmail, aScreenName: userName, aDesc: userDescription, anImageURL: userImage)
            
            self.searchUser.append(newUser)
        }
    }

    func listenToFirebase() {
        ref.child("users").observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
        })
        
        // 2. get the snapshot
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            // 3. convert snapshot to dictionary
            guard let info = snapshot.value as? NSDictionary else {return}
            // 4. add student to array of messages
            self.addUser(id: snapshot.key, userInfo: info)
            
            // sort
            self.searchUser.sort(by: { (user1, user2) -> Bool in
                return user1.id  < user2.id
                
                //LATER NEED TO CHANGE TO SORT BY POST TIME
            })
            
            // set last message id to last id
            if let lastUser = self.searchUser.last {
                self.lastUserId = lastUser.userPostId
                
            }
            
            // 5. update table view
            self.userTableView.reloadData()
            
        })

    }
}

extension SearchViewController : UITableViewDelegate , UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchUser.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellIdentifier) as? SearchTableViewCell
            else { return UITableViewCell() }
        
        let currentUser = searchUser[indexPath.row]
        
        let userImage = currentUser.imageURL
        let selectedUser = currentUser.screenName
        
        cell.userImageView.loadImageUsingCacheWithUrlString(urlString: userImage)
        cell.userLabel.text = selectedUser
        
//        cell.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
        
        return cell

    }
}
