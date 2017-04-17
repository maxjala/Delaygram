//
//  DetailViewController.swift
//  Delaygram
//
//  Created by Obiet Panggrahito on 17/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var shortBioTextView: UITextView!
    @IBOutlet weak var displayPictureImageView: UIImageView!
    @IBOutlet weak var uploadDisplayPictureButton: UIButton! {
        didSet {
            uploadDisplayPictureButton.addTarget(self, action: #selector(uploadDisplayPictureButtonTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        }
    }
    
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
    }

    func signUpButtonTapped () {
        let post : [String : String] = ["screenName": usernameTextField.text!, "desc" : shortBioTextView.text]
            self.ref.child("users").child("\(currentUserID)").updateChildValues(post)
            
            self.directToMainViewController()
    }
    
    func directToMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier:"ViewController") as! ViewController
        self.present(viewController, animated: true)
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        self.directToMainViewController()
    }
    
    func uploadDisplayPictureButtonTapped () {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func dismissimagePicker () {
        dismiss(animated: true, completion: nil)
    }
    
    let dateFormat : DateFormatter = {
        
        let _dateFormatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        _dateFormatter.locale = locale
        _dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return _dateFormatter
    }()
    
    func saveImagePath (downloadPath: String, referencePath: String) {
        
        let dbRef = FIRDatabase.database().reference()
        let imageValue : [String : Any] = [
            "timeStamp" : dateFormat.string(from : Date()),
            "imageUrl" : downloadPath,
            "referencePath" : referencePath]
        
        dbRef.child("users").child(currentUserID).child("imageURL").setValue(imageValue)
    }

    //End of DetailViewController
}

extension DetailViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate { //cannot put variable inside
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //dismiss once you finish
        defer {
            dismissimagePicker()
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            else { return }
        
        //display and store
        uploadImage(image)
    }
    
    func uploadImage (_ image: UIImage) {
        
        let ref = FIRStorage.storage().reference()
        
        //convert image to data
        guard let imageData = UIImageJPEGRepresentation(image, 0.5)
            else { return }
        let metaData = FIRStorageMetadata ()
        
        metaData.contentType = "image/JPEG"
        ref.child(uniqueFileForUser("Yohan")).put(imageData, metadata: metaData) {
            (meta, error) in
            
            if let downloadPath = meta?.downloadURL()?.absoluteString,
                let referencePath = meta?.storageReference?.fullPath {
                
                //save to Firebase
                self.saveImagePath(downloadPath: downloadPath, referencePath: referencePath)
            }
        }
    }
    
    //create unique file name
    func uniqueFileForUser (_ name : String) -> String {
        
        let currentDate = Date()
        return"\(name)_\(currentDate.timeIntervalSince1970).jpeg"
    }
    
    func downloadImage (_ reference: String) {
        let storageRef = FIRStorage.storage().reference()
        
        storageRef.child(reference).data(withMaxSize: 1*102*1024) { (data, error) in _ = UIImage(data: data!)
        }
    }
    
    func observeImage () {
        let dbRef = FIRDatabase.database().reference().child("chat")
        dbRef.observe(.childAdded, with: { (snapshot) in
            
            let chatDictionary = snapshot.value as? [String: Any]
            if let refPath = chatDictionary?["referencePath"] as? String {
                self.downloadImage(refPath)
            }
        })
    }
    
    //End of extension
}
