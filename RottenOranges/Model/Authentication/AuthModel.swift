//
//  AuthModel.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

import FirebaseStorage

class AuthModel {
    
    // Function to update the current user's 'follow' list
    func followPost(for postTitle: String, completion: @escaping (Error?) -> Void) {
        getCurrentUserDetails { userDetails, error in
            guard error == nil else {
                completion(error)
                return
            }

            var updatedFollows = userDetails["follows"] as? [String] ?? []
            // Check if the post title is not already in the 'follows' list
            if !updatedFollows.contains(postTitle) {
                updatedFollows.append(postTitle)
                let db = Firestore.firestore()
                let email = userDetails["email"] as? String ?? ""
                
                // Query Firestore to find the user document using email
                let usersRef = db.collection("users")
                let query = usersRef.whereField("email", isEqualTo: email)
                
                query.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    // Check if any document matches the query
                    if let document = querySnapshot?.documents.first {
                        // Document found, update 'follows' field
                        document.reference.updateData(["follows": updatedFollows]) { error in
                            if let error = error {
                                completion(error)
                            } else {
                                completion(nil)
                            }
                        }
                    } else {
                        let error = NSError(domain: "User document not found", code: 0, userInfo: nil)
                        completion(error)
                    }
                }
            } else {
                // Post title already exists in 'follows' list
                completion(nil)
            }
        }
    }
    
    func getCurrentUserDetails(completion: @escaping ([String: Any], Error?) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            // Fetch basic user details from Firebase Authentication
            let email = currentUser.email ?? ""
            
            // Query Firestore to fetch additional user details including role using email
            let db = Firestore.firestore()
            let usersRef = db.collection("users")
            let query = usersRef.whereField("email", isEqualTo: email)
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion([:], error)
                } else {
                    // Check if any document matches the query
                    if let document = querySnapshot?.documents.first {
                        // Document found, extract user details including role
                        let userData = document.data()
                        let role = userData["role"] as? String ?? ""
                        let name = userData["name"] as? String ?? ""
                        let email = userData["email"] as? String ?? ""
                        let follows = userData["follows"] as? [String] ?? []
                        let tags = userData["tags"] as? [String] ?? []
                        let profileImageURL = userData["profileImageURL"] as? String ?? ""
                        let rating = userData["rating"] as? Double? ?? 0
                        
                        // Create a User object with fetched details
                        let user: [String: Any] = [
                            "name": name,
                            "email": email,
                            "role": role,
                            "follows" : follows,
                            "tags" : tags,
                            "profileImageURL": profileImageURL,
                            "rating": rating
                        ]
                        completion(user, nil)
                    } else {
                        // Document not found
                        let error = NSError(domain: "User document not found", code: 0, userInfo: nil)
                        completion([:], error)
                    }
                }
            }
        } else {
            // No user logged in
            let error = NSError(domain: "User not logged in", code: 0, userInfo: nil)
            completion([:], error)
        }
    }
    
    func getUserByUsername(username: String, completion: @escaping ([String: Any]?, String?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Query Firestore to find the user document using the username field
        let usersRef = db.collection("users")
        let query = usersRef.whereField("name", isEqualTo: username)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle error
                completion(nil, nil, error)
            } else {
                // Check if any document matches the query
                if let document = querySnapshot?.documents.first {
                    // Document found, return user details and document ID
                    let userData = document.data()
                    let documentId = document.documentID
                    completion(userData, documentId, nil)
                } else {
                    // Document not found
                    let error = NSError(domain: "User document not found", code: 0, userInfo: nil)
                    completion(nil, nil, error)
                }
            }
        }
    }


    // Function to edit a user's details using documentId
    func editUser(documentId: String, updatedData: [String: Any], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Reference to the user document by documentId
        let userRef = db.collection("users").document(documentId)
        
        // Update the user document with the provided data
        userRef.updateData(updatedData) { error in
            if let error = error {
                // Return the error if the update fails
                completion(error)
            } else {
                // Return nil if the update is successful
                completion(nil)
            }
        }
    }

    
    // Create a new user in Firestore
    func createUser(name: String, email: String, imageData: Data?, role: String, tags: [String], rating: Double, ratingCount: Int, completion: @escaping (User?, Error?) -> Void) {
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference().child("userImages/\(UUID().uuidString).jpg") // Create a unique filename
        
        var newUserRef: DocumentReference?

        var userData: [String: Any] = [
            "name": name,
            "email": email,
            "role": role,
            "follows" : [],
            "tags" : tags,
            "rating" : rating,
            "ratingCount" : ratingCount
        ]

        if let imageData = imageData {
            // Upload image data to Firebase Storage
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                guard let _ = metadata else {
                    completion(nil, error ?? NSError(domain: "Unknown error occurred while uploading image", code: 0, userInfo: nil))
                    return
                }
                
                // Get download URL for the uploaded image
                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url {
                        // Add image URL to user data
                        userData["profileImageURL"] = downloadURL.absoluteString
                        
                        // Add user data to Firestore
                        newUserRef = db.collection("users").addDocument(data: userData) { error in
                            if let error = error {
                                completion(nil, error)
                                return
                            }

                            guard let userId = newUserRef?.documentID else {
                                completion(nil, NSError(domain: "User document ID is nil", code: 0, userInfo: nil))
                                return
                            }

                            let newUser = User(id: userId, name: name, email: email)
                            completion(newUser, nil)
                        }
                    } else {
                        completion(nil, error ?? NSError(domain: "Unknown error occurred while retrieving image URL", code: 0, userInfo: nil))
                    }
                }
            }
        } else {
            // Add user data to Firestore without image
            newUserRef = db.collection("users").addDocument(data: userData) { error in
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let userId = newUserRef?.documentID else {
                    completion(nil, NSError(domain: "User document ID is nil", code: 0, userInfo: nil))
                    return
                }

                let newUser = User(id: userId, name: name, email: email)
                completion(newUser, nil)
            }
        }
    }
}

