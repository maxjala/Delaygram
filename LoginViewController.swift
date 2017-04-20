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
        }
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
        
        facebookLoginButton.delegate = self as! FBSDKLoginButtonDelegate
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
        let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        self.present(viewController, animated: true)
    }
    
//End of LoginViewController
}

extension LoginViewController : GIDSignInUIDelegate {
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
    
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
    
    }
}

