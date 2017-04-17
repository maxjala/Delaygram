//
//  picturePost.swift
//  Delaygram
//
//  Created by Max Jala on 15/04/2017.
//  Copyright © 2017 TeamDiamonds. All rights reserved.
//

import Foundation

class PicturePost {
    var imagePostID: Int = 0
    var userID : String = ""
    var userScreenName : String = ""
    var userProfileImageURL : String = ""
    
    var imagePostURL : String = ""
    var caption : String = ""
    var timestamp : String = ""
    
    init(anID: Int, aUserID: String, aUserScreenName: String, aUserProfileImageURL: String, anImagePostURL: String, aCaption: String, aTimeStamp: String) {
        imagePostID = anID
        userID = aUserID
        userScreenName = aUserScreenName
        userProfileImageURL = aUserProfileImageURL
        imagePostURL = anImagePostURL
        caption = aCaption
        timestamp = aTimeStamp
        
    }
}
