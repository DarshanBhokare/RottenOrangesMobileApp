//
//  ShowReviewViewController.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import UIKit

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


        
    }
    


}
