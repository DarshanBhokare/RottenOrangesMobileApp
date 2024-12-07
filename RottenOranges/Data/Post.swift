//
//  Post.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/5/24.
//

import Foundation
import FirebaseFirestore

struct Post {
    let title: String
    let content: String
    let timestamp: Date
    let image: String
    let tags: [String]
    let author: String
    let authorRef: DocumentReference
    let rating: Double
}
