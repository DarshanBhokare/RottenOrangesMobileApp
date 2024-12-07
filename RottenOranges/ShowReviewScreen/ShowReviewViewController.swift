//
//  ShowReviewViewController.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class ShowReviewViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let showReviewScreen = ShowReviewView()
    private let review: Post
    
    init(review: Post) {
        self.review = review
        super.init(nibName: nil, bundle: nil)
    }
    override func loadView() {
        view = showReviewScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.title = "Detailed Review"
        showReviewScreen.reviewTitleLabel.text = "Title: \(review.title)"
        showReviewScreen.reviewContentLabel.text = "Review: \(review.content)"
        showReviewScreen.authorLabel.text = "Author: \(review.author)"
        showReviewScreen.movieRatingLabel.text = "Movie Rating: \(review.rating)"
        
        showReviewScreen.submitRatingButton.addTarget(self, action: #selector(submitRatingButtonTapped), for: .touchUpInside)


        
    }
    
    
    @objc func submitRatingButtonTapped() {
        
        let db = Firestore.firestore()

        AuthModel().getUserByUsername(username: review.author) { (userDetails, documentId, error) in
            if let error = error{
                // Handle error
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }
            
            guard let userId = Auth.auth().currentUser?.uid else {
                print("Error: No user logged in.")
                return
            }
            
            guard let userDetails = userDetails, let documentId = documentId else {
                print("Error: User or Document ID not found for author: \(self.review.author)")
                return
            }
            
            let ratingCount = userDetails["ratingCount"] as? Int ?? 0
            let existingRating = userDetails["rating"] as? Double ?? 0.0
            
            // Get the new rating from the text field
            guard let newRatingText = self.showReviewScreen.authorRating.text,
                  let newRating = Double(newRatingText), newRating > 0 else {
                print("Invalid rating provided.")
                return
            }
            
            let updatedRatingCount = ratingCount + 1
            let totalRating = (existingRating * Double(ratingCount)) + newRating
            let newAverageRating = totalRating / Double(updatedRatingCount)
            
            // Prepare data to update in Firebase
            let updatedData: [String: Any] = [
                "ratingCount": updatedRatingCount,
                "rating": newAverageRating
            ]
            
            // Update the data in Firebase
            db.collection("users").document(documentId).updateData(updatedData) { error in
            if let error = error {
                print("Error updating Firestore document: \(error.localizedDescription)")
            } else {
                print("Successfully updated the user rating in Firestore.")
                DispatchQueue.main.async {
                    // Navigate back to the previous screen
                    self.navigationController?.popViewController(animated: true)
                }
            }
          }
                
            
            
        }
    }


}
