//
//  EditProfileViewController.swift
//  Delaygram
//
//  Created by Obiet Panggrahito on 18/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView! {
        didSet {
            bioTextView.layer.borderColor = UIColor.lightGray.cgColor
            bioTextView.layer.borderWidth = 0.2
            bioTextView.layer.cornerRadius = 5
            bioTextView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var displayImageView: UIImageView! {
        didSet {
            displayImageView.layer.cornerRadius = displayImageView.frame.width/2
            displayImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var uploadPhotoButton: UIButton! {
        didSet {
            uploadPhotoButton.addTarget(self, action: #selector(uploadPhotoButtonTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        }
    }
    
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    var profileImageURL : String? = ""
    var profileScreenName : String? = ""
    var profileDesc : String? = ""
    
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
            
            var dict = snapshot.value as? [String : Any]
            
            self.profileScreenName = dict?["screenName"] as? String
            self.profileImageURL = dict?["imageURL"] as? String
            self.profileDesc = dict?["desc"] as? String
            
            print("")
            
            self.setUpProfile()
        })
    }
    
    func setUpProfile () {
        usernameTextField.text = profileScreenName
        bioTextView.text = profileDesc
        
        let imageURL = profileImageURL
        displayImageView.loadImageUsingCacheWithUrlString(urlString: imageURL!)
        
        
        print("")
    }

    
    func doneButtonTapped () {

        let profileUpdate : [String: String] = ["screenName": usernameTextField.text!, "desc": bioTextView.text]
        ref.child("users").child(currentUserID).updateChildValues(profileUpdate)
        
        dismiss(animated: true, completion: nil)
    }

    func uploadPhotoButtonTapped () {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    
    }
    
    func dismissImagePicker() {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(_ image: UIImage) {
    
        let ref = FIRStorage.storage().reference()
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        ref.child("\(String(describing: currentUser?.email))-\(createTimeStamp()).jpeg").put(imageData, metadata: metaData) { (meta, error) in
                if let downloadPath = meta?.downloadURL()?.absoluteString {
                //save to firebase database
                self.saveImagePath(downloadPath)
    
                print("")
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
    
    func saveImagePath(_ path: String) {
        let profileValue : [String: Any] = ["imageURL": path]
            
        ref.child("users").child(currentUserID).updateChildValues(profileValue)
    }

// End of EditProfileViewController
}

extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

