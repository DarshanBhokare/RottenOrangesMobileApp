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
        showReviewScreen.reviewContentLabel.text = "\(review.content)"
        showReviewScreen.authorLabel.text = "Author: \(review.author)"
        showReviewScreen.movieRatingLabel.text = "Movie Rating: \(review.rating)"
        
        showReviewScreen.submitRatingButton.addTarget(self, action: #selector(submitRatingButtonTapped), for: .touchUpInside)


        
    }
    
    func showAlert(message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc func submitRatingButtonTapped() {
        let db = Firestore.firestore()

        // Validate the rating input
        guard let newRatingText = showReviewScreen.authorRating.text,
              let newRating = Double(newRatingText),
              (0...10).contains(newRating) else {
            showAlert(message: "Invalid rating. Please provide a number between 0 and 10.")
            return
        }

        AuthModel().getUserByDocumentReference(userRef: review.authorRef) { (userDetails, documentId, error) in
            if let error = error {
                // Handle error
                self.showAlert(message: "Error fetching user details: \(error.localizedDescription)")
                return
            }

            guard let userId = Auth.auth().currentUser?.uid else {
                self.showAlert(message: "Error: No user logged in.")
                return
            }

            guard let userDetails = userDetails, let documentId = documentId else {
                self.showAlert(message: "Error: User or Document ID not found for author: \(self.review.author)")
                return
            }

            let ratingCount = userDetails["ratingCount"] as? Int ?? 0
            let existingRating = userDetails["rating"] as? Double ?? 0.0

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
                    self.showAlert(message: "Error updating Firestore document: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(message: "Rating submitted successfully!") { _ in
                            // Navigate back to the previous screen
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }



}
