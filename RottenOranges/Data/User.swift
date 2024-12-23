//
//  User.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/5/24.
//

import Foundation
import UIKit
import FirebaseFirestore

struct User{
    var id: String?
    var name:String?
    var email:String?
    var followedCritics: [DocumentReference]?
    var rating: Double
    
    
    
    init(
         id: String? = nil,
         name: String? = nil,
         email: String? = nil,
         followedCritics: [DocumentReference]? = [],
         rating: Double? = 0.0
         ) {
        self.id = id;
        self.name = name
        self.email = email
        self.followedCritics = followedCritics
        self.rating = rating ?? 0.0
    }
    
}

