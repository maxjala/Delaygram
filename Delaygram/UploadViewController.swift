//
//  UploadViewController.swift
//  Delaygram
//
//  Created by Max Jala on 15/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class UploadViewController: UIViewController {
    
    
    @IBOutlet weak var uploadImageView: UIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enableImagePicker))
            uploadImageView.isUserInteractionEnabled = true
            uploadImageView.addGestureRecognizer(tapGestureRecognizer)
            //uploadImageView.loadImageUsingCacheWithUrlString(urlString: uploadImageURL)
        }
    }
    
    @IBOutlet weak var captionTextView: UITextView! {
        didSet{
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removePlaceholderText))
                captionTextView.isUserInteractionEnabled = true
                captionTextView.addGestureRecognizer(tapGestureRecognizer)

        }
    }
    
    @IBOutlet weak var chooseImageLabel: UILabel! {
        didSet{
            chooseImageLabel.layer.borderColor = UIColor.black.cgColor
            chooseImageLabel.layer.borderWidth = 2.0
        }
    }
    
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    var currentUserEmail : String = ""
    var profileScreenName : String = ""
    var profileImageURL : String = ""
    
    var uploadImageURL : String = ""
    var newPost : PicturePost?
    var personalPosts : [PicturePost] = []
    //var lastID = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentUser()
        enableImagePicker()

        // Do any additional setup after loading the view.

    }
    
    func setCurrentUser() {
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let id = currentUser?.uid,
            let email = currentUser?.email {
            print(id)
            currentUserID = id
            currentUserEmail = email
        }
        
        
        self.ref.child("users").child(currentUserID).observe(.value, with: { (userSS) in
            print("Value : " , userSS)
            
            let dictionary = userSS.value as? [String: Any]
            
            self.profileScreenName = (dictionary?["screenName"])! as! String
            self.profileImageURL = (dictionary?["imageURL"])! as! String
            
        })
        
    }
    
    func removePlaceholderText() {
        if captionTextView.text == "Write a caption..." {
            captionTextView.text = ""
            captionTextView.isUserInteractionEnabled = true
            captionTextView.font = captionTextView.font?.withSize(14)
            captionTextView.textColor = UIColor.black
        } else {
            return
        }
    }
    

    
    @IBAction func postButtonTapped(_ sender: Any) {
        
        let currentDate = NSDate()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        let uniqueTimeID = Int(currentDate.timeIntervalSince1970)
        let timeCreated = dateFormatter.string(from: currentDate as Date)
        
        
           if let caption = self.captionTextView.text {
            // write to firebase
            let post : [String : Any] = ["userID": self.currentUserID, "screenName": self.profileScreenName, "caption": caption, "profileImageURL": self.profileImageURL, "postedImageURL" : self.uploadImageURL, "timestamp": timeCreated]
            
            let personalReference : [String : Any] = ["userID" : currentUserID, "postID" : uniqueTimeID]
            
            self.ref.child("posts").child("\(uniqueTimeID)").updateChildValues(post)
            //self.ref.child("users").child(currentUserID).child("posts").child("\(uniqueTimeID)").updateChildValues(post)
            
            self.ref.child("users").child(currentUserID).child("posts").child("\(uniqueTimeID)").updateChildValues(personalReference)

        }
        
        
    }


    func enableImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    func dismissImagePicker() {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(_ image: UIImage) {
        
        let ref = FIRStorage.storage().reference()
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {return}
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        ref.child("\(currentUser?.email)-\(createTimeStamp()).jpeg").put(imageData, metadata: metaData) { (meta, error) in
            
            if let downloadPath = meta?.downloadURL()?.absoluteString {
                
                //save to firebase database
                //self.saveImagePath(downloadPath)
                self.uploadImageURL = downloadPath
                self.uploadImageView.loadImageUsingCacheWithUrlString(urlString: self.uploadImageURL)
                
            }
            
        }
        
        
    }
    
    func createTimeStamp() -> String {
        
        let currentDate = NSDate()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        let timeCreated = dateFormatter.string(from: currentDate as Date)
        
        return timeCreated
        
    }
    

}


extension UploadViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            dismissImagePicker()
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        //display / store
        uploadImage(image)
        
    }
    
    func uniqueFileForUser(_ name: String) -> String {
        let currentDate = Date()
        return "\(name)_\(currentDate.timeIntervalSince1970).jpeg"
    }
    
    
}
