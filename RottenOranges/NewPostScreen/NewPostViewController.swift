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
    var authorImageURL: String?
    
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
    
    @objc func saveBtnTapped() {
        let postTitle = newPostScreen.titleTextField.text ?? ""
        let postContent = newPostScreen.contentTextView.text ?? ""
        let movieRatingText = newPostScreen.movieRatingTextField.text ?? ""
        var author = ""
        var tags: [String] = []

        // Validate title and content
        if postTitle.isEmpty || postContent.isEmpty {
            showAlert(message: "Title or content cannot be empty.")
            return
        }

        // Validate movie rating
        guard let movieRating = Double(movieRatingText), (0...10).contains(movieRating) else {
            showAlert(message: "Invalid rating. Please provide a number between 0 and 10.")
            return
        }

        // Get tags and author name from current user
        AuthModel().getCurrentUserDetails { (userDetails, error) in
            if let error = error {
                self.showAlert(message: "Error fetching user details: \(error.localizedDescription)")
                return
            }

            if let name = userDetails["name"] as? String {
                author = name
            }

            if let authorImageURL = userDetails["profileImageURL"] as? String {
                self.authorImageURL = authorImageURL
            }

            if let experts = userDetails["tags"] as? [String] {
                tags = experts
            }

            guard let email = userDetails["email"] as? String else {
                self.showAlert(message: "User email not found.")
                return
            }

            // Fetch user's DocumentReference
            let db = Firestore.firestore()
            let usersRef = db.collection("users")
            let query = usersRef.whereField("email", isEqualTo: email)

            query.getDocuments { querySnapshot, error in
                if let error = error {
                    self.showAlert(message: "Error fetching user document: \(error.localizedDescription)")
                    return
                }

                guard let document = querySnapshot?.documents.first else {
                    self.showAlert(message: "User document not found.")
                    return
                }

                let authorRef = document.reference

                // Create a new post
                let newPost = Post(
                    title: postTitle,
                    content: postContent,
                    timestamp: Date(),
                    image: self.authorImageURL ?? "",
                    tags: tags,
                    author: author,
                    authorRef: authorRef,
                    rating: movieRating
                )

                // Prepare post data
                let postData: [String: Any] = [
                    "title": newPost.title,
                    "content": newPost.content,
                    "timestamp": newPost.timestamp,
                    "image": newPost.image,
                    "tags": newPost.tags,
                    "author": newPost.author,
                    "authorRef": newPost.authorRef,
                    "rating": newPost.rating
                ]

                // Add post to Firestore
                db.collection("posts").addDocument(data: postData) { error in
                    if let error = error {
                        self.showAlert(message: "Error adding document: \(error.localizedDescription)")
                    } else {
                        self.showAlert(message: "Post created successfully!") { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }

    private func showAlert(message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func hideKeyboardOnTap() {
        view.endEditing(true)
    }
}
