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

class SearchViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var userTableView: UITableView! {
        didSet{
            userTableView.delegate = self
            userTableView.dataSource = self
            
            userTableView.register(SearchTableViewCell.cellNib, forCellReuseIdentifier: SearchTableViewCell.cellIdentifier)
        }
    }
    
    @IBOutlet weak var userSearchBar: UISearchBar!{
        didSet{
            userSearchBar.delegate = self
        }
    }
    var searchActive: Bool = false
    var allUsers: [User] = []
    var filteredUsers: [User] = []
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
    
    //MARK search Bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    func addUser(id: Any , userInfo:NSDictionary){
        if
            let userName = userInfo["screenName"] as? String,
            let userImage = userInfo["imageURL"] as? String,
            let userId = id as? String,
            let userEmail = userInfo["email"] as? String,
            let userDescription = userInfo["desc"] as? String {

            let newUser = User(anId: userId, anEmail: userEmail, aScreenName: userName, aDesc: userDescription, anImageURL: userImage)
            
            if newUser.id != currentUserId {
            self.allUsers.append(newUser)
            }
            
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
            self.allUsers.sort(by: { (user1, user2) -> Bool in
                return user1.screenName  < user2.screenName
                
                //LATER NEED TO CHANGE TO SORT BY POST TIME
            })
            
            self.filteredUsers = self.allUsers
            
            
            // 5. update table view
            self.userTableView.reloadData()
            
        })

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if searchText.characters.count == 0 {
            
            filteredUsers = allUsers;
            self.userTableView.reloadData()
            return
        }
        
        
        
        filteredUsers = allUsers.filter({ (user) -> Bool in
            let nameString: NSString = user.screenName as NSString
            let range = nameString.range(of: searchText, options: .caseInsensitive)
            return range.location != NSNotFound
        })
        
   
        
        self.userTableView.reloadData()
}
    
}

extension SearchViewController : UITableViewDelegate , UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellIdentifier) as? SearchTableViewCell
            else { return UITableViewCell() }
        
        
        let currentUser = filteredUsers[indexPath.row]
        
        let userImage = currentUser.imageURL
        let selectedUser = currentUser.screenName
        
        cell.userImageView.loadImageUsingCacheWithUrlString(urlString: userImage)
        cell.userLabel.text = selectedUser
        checkFollowing(indexPath: indexPath, sender: cell.followButton)
        
        cell.followButton.tag = indexPath.row
        cell.followButton.addTarget(self, action: #selector(followButtonTapped(sender:)), for: .touchUpInside)

        
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "PersonalProfileViewController") as? PersonalProfileViewController {
        
            let selectedPerson = filteredUsers[indexPath.row]

            controller.selectedProfile = selectedPerson
            controller.profileType = .otherProfile
            controller.currentUserID = selectedPerson.id
            navigationController?.pushViewController(controller, animated: true)
        }
        
    }

    
    func followButtonTapped(sender:UIButton) {
        
        
        let buttonRow = sender.tag
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (ke, value) in following {
                    if value as! String == self.allUsers[buttonRow].id {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.allUsers[buttonRow].id).child("followers/\(ke)").removeValue()
                        
                        (sender as AnyObject).setTitle("Follow", for: .normal)
                        
                        
                    }
                }
            }
            if !isFollower {
                let following = ["following/\(key)" : self.allUsers[buttonRow].id]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.allUsers[buttonRow].id).updateChildValues(followers)
                
                (sender as AnyObject).setTitle("Following", for: .normal)
            }
        })
        ref.removeAllObservers()
        
        
    }
    

    
    func checkFollowing(indexPath: IndexPath, sender: UIButton) {

        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (_, value) in following {
                    if value as! String == self.allUsers[indexPath.row].id {
                        //self.userTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                        (sender as AnyObject).setTitle("Following", for: .normal)
                    }
                }
            }
        })
        ref.removeAllObservers()
        
    }
    
}
