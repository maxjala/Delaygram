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
    var desc : String
    var imageURL : String
    
    init( ) {
        id = ""
        email = ""
        screenName = ""
        desc = ""
        imageURL = ""
    }
    
    init(anId : String, anEmail : String, aScreenName : String, aDesc : String, anImageURL : String) {
        id = anId
        email = anEmail
        screenName = aScreenName
        desc = aDesc
        imageURL = anImageURL
    }
}
