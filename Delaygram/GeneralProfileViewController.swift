//
//  GeneralProfileViewController.swift
//  Delaygram
//
//  Created by Max Jala on 19/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class GeneralProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var selectedProfile : User?
    var ref: FIRDatabaseReference!
    var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var currentUserID : String = ""
    
    
    
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        setCurrentUser()
        
        

        // Do any additional setup after loading the view.
    }
    
    func setCurrentUser() {
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
