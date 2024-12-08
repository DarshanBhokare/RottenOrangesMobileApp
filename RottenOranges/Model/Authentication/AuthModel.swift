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
    func followUser(for userRef: DocumentReference, completion: @escaping (Error?) -> Void) {
        getCurrentUserDetails { userDetails, error in
            guard error == nil else {
                completion(error)
                return
            }

            var updatedFollows = userDetails["follows"] as? [DocumentReference] ?? []
            // Check if the userRef is not already in the 'follows' list
            if !updatedFollows.contains(where: { $0.path == userRef.path }) {
                updatedFollows.append(userRef)
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
                // UserRef already exists in 'follows' list
                completion(nil)
            }
        }
    }
    
    // Get current user details
    func getCurrentUserDetails(completion: @escaping ([String: Any], Error?) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            let email = currentUser.email ?? ""
            let db = Firestore.firestore()
            let usersRef = db.collection("users")
            let query = usersRef.whereField("email", isEqualTo: email)
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion([:], error)
                } else if let document = querySnapshot?.documents.first {
                    // Document found, extract user details
                    var userData = document.data()
                    userData["follows"] = document.get("follows") as? [DocumentReference] ?? []
                    completion(userData, nil)
                } else {
                    let error = NSError(domain: "User document not found", code: 0, userInfo: nil)
                    completion([:], error)
                }
            }
        } else {
            let error = NSError(domain: "User not logged in", code: 0, userInfo: nil)
            completion([:], error)
        }
    }
    
    // Get user by username
    func getUserByUsername(username: String, completion: @escaping ([String: Any]?, String?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Query Firestore to find the user document using the username field
        let usersRef = db.collection("users")
        let query = usersRef.whereField("name", isEqualTo: username)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, nil, error)
            } else if let document = querySnapshot?.documents.first {
                // Document found, return user details and document ID
                let userData = document.data()
                let documentId = document.documentID
                completion(userData, documentId, nil)
            } else {
                let error = NSError(domain: "User document not found", code: 0, userInfo: nil)
                completion(nil, nil, error)
            }
        }
    }

    // Get user by document reference
    func getUserByDocumentReference(userRef: DocumentReference, completion: @escaping ([String: Any]?, String?, Error?) -> Void) {
        userRef.getDocument { document, error in
            if let error = error {
                completion(nil, nil, error)
            } else if let document = document, document.exists {
                let userData = document.data()
                let documentId = document.documentID
                completion(userData, documentId, nil)
            } else {
                let error = NSError(domain: "User document not found", code: 0, userInfo: nil)
                completion(nil, nil, error)
            }
        }
    }
    
    // Edit user details using documentId
    func editUser(documentId: String, updatedData: [String: Any], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(documentId)
        
        userRef.updateData(updatedData) { error in
            completion(error)
        }
    }

    // Create a new user in Firestore
    func createUser(name: String, email: String, imageData: Data?, role: String, tags: [String], rating: Double, ratingCount: Int, completion: @escaping (User?, Error?) -> Void) {
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference().child("userImages/\(UUID().uuidString).jpg")
        
        var newUserRef: DocumentReference?
        var userData: [String: Any] = [
            "name": name,
            "email": email,
            "role": role,
            "follows": [],
            "tags": tags,
            "rating": rating,
            "ratingCount": ratingCount
        ]

        if let imageData = imageData {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                guard metadata != nil else {
                    completion(nil, error)
                    return
                }
                storageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        userData["profileImageURL"] = downloadURL.absoluteString
                        newUserRef = db.collection("users").addDocument(data: userData) { error in
                            if let error = error {
                                completion(nil, error)
                            } else if let userId = newUserRef?.documentID {
                                let newUser = User(id: userId, name: name, email: email)
                                completion(newUser, nil)
                            }
                        }
                    } else {
                        completion(nil, error)
                    }
                }
            }
        } else {
            newUserRef = db.collection("users").addDocument(data: userData) { error in
                if let error = error {
                    completion(nil, error)
                } else if let userId = newUserRef?.documentID {
                    let newUser = User(id: userId, name: name, email: email)
                    completion(newUser, nil)
                }
            }
        }
    }
}
