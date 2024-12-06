//
//  NewPostViewController.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/5/24.
//

import UIKit
import FirebaseFirestoreInternal
import PhotosUI
import FirebaseStorage

class NewPostViewController: UIViewController {

    let newPostScreen = NewPostView()
    var authorImage:UIImage?
    
    override func loadView() {
       view = newPostScreen
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
            tapRecognizer.cancelsTouchesInView = false
            view.addGestureRecognizer(tapRecognizer)
        
        title = "Create Post"
    
        newPostScreen.saveButton.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        
    }
    
    @objc func saveBtnTapped(){
        let postTitle = newPostScreen.titleTextField.text ?? ""
        let postContent = newPostScreen.contentTextView.text ?? ""
        let movieRating = newPostScreen.movieRatingTextField.text ?? ""
        var author = ""
        var tags: [String] = []
        
        if postTitle.isEmpty || postContent.isEmpty {
            showAlert(message: "Title or content cannot be empty.")
            return
        }
        
        // Get tags and author name from current user
        AuthModel().getCurrentUserDetails { (userDetails, error) in
            if let error = error {
                // Handle error
                print("Error fetching user details: \(error.localizedDescription)")
            } else {
                if let error = error {
                    // Handle error
                    print("Error fetching user details: \(error.localizedDescription)")
                } else {
                    if let name = userDetails["name"] as? String {
                        author = name
                    } else {
                        author = ""
                    }
                    
                    if let experts = userDetails["tags"] as? [String] {
                        tags = experts
                    } else {
                        tags = []
                    }
                }
                
                // TODO: Get authors profile picture here instead
                self.authorImage = UIImage(systemName: "person.fill")

                
                if let image = self.authorImage {
                    // Convert the image to JPEG data
                    guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                        print("Failed to convert image to data.")
                        return
                    }
                    
                    let storageRef = Storage.storage().reference().child("userImages/\(UUID().uuidString).jpg") // Create a unique filename

                    // Upload image data to Firebase Storage
                    storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                        guard let metadata = metadata else {
                            print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        // You can access the download URL for the image from the metadata
                        storageRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                // Uh-oh, an error occurred!
                                print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                                return
                            }
                            
                            let imageUrlString = downloadURL.absoluteString
                            
                            let newPost = Post(title: postTitle, content: postContent, timestamp: Date.now, image: imageUrlString, tags: tags, author: author, rating: Double(movieRating) ?? 0.0)
                    
                            // Create a new post
                            let db = Firestore.firestore()
                            let postData: [String: Any] = [
                                "title": newPost.title,
                                "content": newPost.content,
                                "timestamp": newPost.timestamp,
                                "image": newPost.image,
                                "tags": newPost.tags,
                                "author": newPost.author,
                                "rating": newPost.rating
                            ]
                    
                            db.collection("posts").addDocument(data: postData) { error in
                                if let error = error {
                                    // Handle error while adding document
                                    print("Error adding document: \(error)")
                                } else {
                                    // Post added successfully
                                    print("Document added successfully")
                                }
                            }
                        }
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }



            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func hideKeyboardOnTap(){
        view.endEditing(true)
    }

}

