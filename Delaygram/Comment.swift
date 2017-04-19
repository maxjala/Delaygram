//
//  Comment.swift
//  Delaygram
//
//  Created by Max Jala on 19/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import Foundation

class Comment {
    var id: Int
    var userName : String
    var body : String
    var imageURL : String
    var timestamp : String
    
    init( ) {
        id = 0
        userName = ""
        body = ""
        imageURL = ""
        timestamp = ""
    }
    
    init(anId : Int, aUserName : String, aBody : String, anImageURL : String, aDate : String) {
        id = anId
        userName = aUserName
        body = aBody
        imageURL = anImageURL
        timestamp = aDate
    }
}
