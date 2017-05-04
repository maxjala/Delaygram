//
//  LoginViewController.swift
//  Delaygram
//
//  Created by Obiet Panggrahito on 14/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {

    @IBOutlet weak var emailSigninLabel: UITextField!
    @IBOutlet weak var passwordSigninLabel: UITextField!
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var registerButton: UIButton! {
        didSet {
            registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        }
    }
    
    var databaseRef : FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLogin()
        googleLogin()
        
        if (FIRAuth.auth()?.currentUser) != nil {
            print("User already logged in")
            // go to main page
            directToViewController()
            navigationBarHidden()
            
        }
    }
    
    func navigationBarHidden(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }

    // MARK - Email Login
    func loginButtonTapped () {
        guard let email = emailSigninLabel.text,
            let password = passwordSigninLabel.text
            else { return }
        
        if email == "" || password == "" {
            print ("input error : email / password cannot be empty")
            return
        }
        
        //paste from Sign in existing users in Authentication
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            // ...
            if let err = error {
                print("SignIn Error : \(err.localizedDescription)")
                return
            }
            
            guard let user = user
                else {
                    print("User Error")
                    return
            }
            
            print("User Logged In")
            print("email : \(String(describing: user.email))")
            print("uid : \(user.uid)")
            
            self.directToViewController()
        }
    }
    
    func registerButtonTapped() {
        if let goToSignup = storyboard?.instantiateViewController(withIdentifier: "SignupViewController") {
            present(goToSignup, animated: true, completion: nil)
        }
    }

    // MARK - Facebook loggin
    func facebookLogin () {
        if (FBSDKAccessToken.current() == nil) { print("Facebook Not logged in") }
        else { print("Facebook Logged in") }
        
        let facebookLoginButton = FBSDKLoginButton()
        facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        facebookLoginButton.center = self.view.center
        facebookLoginButton.frame = CGRect(x: 107, y: 417, width: 200, height: 42)
        facebookLoginButton.delegate = self
        
        self.view.addSubview(facebookLoginButton)
    }
    
     // MARK - Google loggin
    func googleLogin () {
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if (GIDSignIn.sharedInstance().currentUser == nil) { print("Google Not logged in") }
        else { print("Google Logged in") }
        
    }
    
    func directToViewController () {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        self.present(viewController, animated: true)
    }
    
//End of LoginViewController
    
}

extension LoginViewController : FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error == nil {
            if (FBSDKAccessToken.current() == nil) {
                dismiss(animated: true, completion: nil)
            } else {
                
                
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                
                let defaultImageURL = "https://firebasestorage.googleapis.com/v0/b/chatapp2-8fc6d.appspot.com/o/icon1.png?alt=media&token=a0c137ff-3053-442b-a6fb-3ef06f818d6a"
                
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    // ...
                    if let err = error {
                        print("Facebook Loggin Error : \(err.localizedDescription)")
                        return
                    }
                    
                    print("user signed in to Firebase")
                    
                    self.databaseRef = FIRDatabase.database().reference()
                    self.databaseRef.child("users").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        let snapshot = snapshot.value as? NSDictionary
                        
                        if(snapshot == nil) {
                            self.databaseRef.child("users").child(user!.uid).child("imageURL").setValue(defaultImageURL)
                            self.databaseRef.child("users").child(user!.uid).child("email").setValue(user!.email)
                            self.databaseRef.child("users").child(user!.uid).child("desc").setValue("Add description")
                            self.databaseRef.child("users").child(user!.uid).child("screenName").setValue("Anonymous")
                        }
                        
                        
                        if let user = user {
                        print("Log in complete")
                        
                        self.directToViewController()
                        }
                        
                    })
                }
            }
        } else {
            print("SignIn Error : \(error.localizedDescription)")
            dismiss(animated: true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
}

extension LoginViewController : GIDSignInUIDelegate {
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
    
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
    
    }
}

