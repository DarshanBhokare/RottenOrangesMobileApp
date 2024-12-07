//
//  Profile.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import Foundation
import UIKit

struct Profile{
    var name: String?
    var email: String?
    var phoneType: String?
    var profileImage: String?
    var phone: Int?
    var role: String?
    var tags: [String]
    var rating: Double?
    var address1: String?
    var address2: String?
    var address3: String?
    var followedCritics : [String]
    
    init(name: String? = nil,
         email: String? = nil,
         followedCritics: [String] = [],
         phoneType: String? = nil,
         profileImage: String? = nil,
         phone: Int? = nil,
         role: String? = nil,
         tags: [String] = [],
         rating: Double? = 0.0,
         address1: String? = nil,
         address2: String? = nil,
         address3: String? = nil) {
        self.name = name
        self.email = email
        self.followedCritics = followedCritics
        self.phoneType = phoneType
        self.profileImage = profileImage
        self.phone = phone
        self.role = role
        self.tags = tags
        self.address1 = address1
        self.address2 = address2
        self.address3 = address3
        self.rating = rating
    }
    
}
