//
//  User.swift
//  Delaygram
//
//  Created by Max Jala on 15/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import Foundation

class User {
    var id: String
    var email : String
    var screenName : String
//    var followers : Array<String>
//    var following : Array<String>
    var desc : String
    var imageURL : String
    
    init( ) {
        id = ""
        email = ""
        screenName = ""
//        followers = []
//        following = []
        desc = ""
        imageURL = ""
    }
    
    init(anId : String, anEmail : String, aScreenName : String,/* followersArray : Array<String>, followingArray : Array<String>,*/ aDesc : String, anImageURL : String) {
        id = anId
        email = anEmail
        screenName = aScreenName
//        followers = followersArray
//        following = followingArray
        desc = aDesc
        imageURL = anImageURL
    }
}
