//
//  SignupViewController.swift
//  Delaygram
//
//  Created by Obiet Panggrahito on 14/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignupViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ref = FIRDatabase.database().reference()
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let logInVC = storyboard?.instantiateViewController(withIdentifier: "AuthNavigationController") {
            present(logInVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let email = userNameTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text else {return}
        
        if email == "" || password == "" || confirmPassword == "" {
            print("Email / password cannot be empty")
        }
        
        if password != confirmPassword {
            print("Passwords do not match");
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            
            let defaultImageURL = "https://firebasestorage.googleapis.com/v0/b/chatapp2-8fc6d.appspot.com/o/icon1.png?alt=media&token=a0c137ff-3053-442b-a6fb-3ef06f818d6a"
            
            if error != nil {
                return
            }
            
            guard let user = user
                else {
                    print ("User not created error")
                    return
            }
            
            print("User ID \(user.uid) with email: \(String(describing: user.email)) created")
            
            let post : [String : String] = ["email": user.email!, "screenName": "ANONYMOUS", "desc": "Add a Description", "imageURL" : defaultImageURL]
            self.ref.child("users").child("\(user.uid)").updateChildValues(post)
            
            self.directToMainViewController()
        }
    }
    func directToMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier:"ViewController") as! ViewController
        self.present(viewController, animated: true)
    }
}

