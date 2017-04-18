//
//  PersonalProfileViewController.swift
//  Delaygram
//
//  Created by nicholaslee on 18/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import Firebase

class PersonalProfileViewController: UIViewController {

    @IBOutlet weak var displayPictureUser: UIImageView! {
        didSet {
            displayPictureUser.layer.cornerRadius = displayPictureUser.frame.width/2
            displayPictureUser.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var numberOfPosts: UILabel!
    
    @IBOutlet weak var numberOfFollowers: UILabel!
    
    @IBOutlet weak var numberOfFollowing: UILabel!
    
    @IBOutlet weak var editButton: UIButton!{
        didSet {
            editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    var profileImageURL : String = ""
    var profileScreenName : String = ""
    var profileDesc : String = ""
    var profileFollowers : String = ""
    var profileFolowing : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
        
        listenToFirebase()
        }
    
    func listenToFirebase () {
        ref.child("users").child(currentUserID).observe(.value, with: { (snapshot) in
            print("Value : " , snapshot)
            
            var dict = snapshot.value as? [String: String]
            
            self.profileScreenName = (dict?["screenName"])!
            self.profileImageURL = (dict?["imageURL"])!
            self.profileDesc = (dict?["desc"])!
//            self.profileFollowers = (dictionary?["followers"])!
//            self.profileFolowing = (dictionary?["following"])!
            
            
            print("")
            
            self.setUpProfile()
        })
    }
    
    func setUpProfile () {
        nameLabel.text = profileScreenName
        bioLabel.text = profileDesc
//        numberOfFollowers.text = profileFollowers.count
//        numberOfFollowing.text = profileFolowing.count
        
        let imageURL = profileImageURL
        displayPictureUser.loadImageUsingCacheWithUrlString(urlString: imageURL)
        
        
        print("")
    }

    
    func editButtonTapped () {
        
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
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
    
//    @IBAction func editPictureButton(_ sender: Any) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        present(imagePicker, animated: true, completion: nil)
//        
//        
//    }
//    
//    
//    
//    func dismissImagePicker() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func uploadImage(_ image: UIImage) {
//        
//        let ref = FIRStorage.storage().reference()
//        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
//        let metaData = FIRStorageMetadata()
//        metaData.contentType = "image/jpeg"
//        ref.child("\(currentUser?.email)-\(createTimeStamp()).jpeg").put(imageData, metadata: metaData) { (meta, error) in
//            
//            if let downloadPath = meta?.downloadURL()?.absoluteString {
//                //save to firebase database
//                self.saveImagePath(downloadPath)
//                
//                print("")
//            }
//            
//        }
//        
//        
//    }
//    
//    func createTimeStamp() -> String {
//        
//        let currentDate = NSDate()
//        let dateFormatter:DateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM-dd HH:mm"
//        let timeCreated = dateFormatter.string(from: currentDate as Date)
//        
//        return timeCreated
//        
//    }
//    
//    func saveImagePath(_ path: String) {
//        
//        let profileValue : [String: Any] = ["imageURL": path]
//        
//        ref.child("users").child(currentUserID).updateChildValues(profileValue)
//    }
//End of PersonalProfileViewController
}

//extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        
//        defer {
//            dismissImagePicker()
//        }
//        
//        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
//            return
//        }
//        
//        //display / store
//        uploadImage(image)
//        
//    }
//    
//    func uniqueFileForUser(_ name: String) -> String {
//        let currentDate = Date()
//        return "\(name)_\(currentDate.timeIntervalSince1970).jpeg"
//    }
//}


