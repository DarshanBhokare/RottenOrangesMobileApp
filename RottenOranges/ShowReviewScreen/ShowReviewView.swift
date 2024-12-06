//
//  ShowReviewView.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import UIKit

class ShowReviewView: UIView {

    var reviewTitleLabel: UILabel!
    var reviewContentLabel: UILabel!
    var authorLabel: UILabel!
    var movieRatingLabel: UILabel!
    
    var authorRating: UITextField!
    
    var submitRatingButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupReviewTitleLabel()
        setupEmailLabel()
        setupAuthorLabel()
        setupMovieRatingLabel()
        setupAuthorRating()
        setupSubmitRatingButton()
        
        initConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupReviewTitleLabel() {
        reviewTitleLabel = UILabel()
        reviewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewTitleLabel.textColor = .black
        reviewTitleLabel.textAlignment = .center
        reviewTitleLabel.font = UIFont.systemFont(ofSize: 20)
        reviewTitleLabel.text = "Title"
        self.addSubview(reviewTitleLabel)
    }
    
    func setupEmailLabel() {
        reviewContentLabel = UILabel()
        reviewContentLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewContentLabel.textColor = .black
        reviewContentLabel.textAlignment = .center
        reviewContentLabel.font = UIFont.systemFont(ofSize: 16)
        reviewContentLabel.text = "Review"
        self.addSubview(reviewContentLabel)
    }
    
    func setupAuthorLabel(){
        authorLabel = UILabel()
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.textColor = .black
        authorLabel.textAlignment = .center
        authorLabel.font = UIFont.systemFont(ofSize: 16)
        authorLabel.text = "Author"
        self.addSubview(authorLabel)
    }
    
    func setupMovieRatingLabel(){
        movieRatingLabel = UILabel()
        movieRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        movieRatingLabel.textColor = .black
        movieRatingLabel.textAlignment = .center
        movieRatingLabel.font = UIFont.systemFont(ofSize: 16)
        movieRatingLabel.text = "Movie Rating"
        self.addSubview(movieRatingLabel)
    }
    
    func setupAuthorRating(){
        authorRating = UITextField()
        authorRating.translatesAutoresizingMaskIntoConstraints = false
        authorRating.borderStyle = .roundedRect
        authorRating.keyboardType = .numberPad
        authorRating.placeholder = "Provide a rating for the reviewer(1-10)"
        self.addSubview(authorRating)
    }
    
    func setupSubmitRatingButton(){
        submitRatingButton = UIButton(type: .system)
        submitRatingButton.translatesAutoresizingMaskIntoConstraints = false
        submitRatingButton.setTitle("Submit Rating", for: .normal)
        
        self.addSubview(submitRatingButton)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

            let allowedCharacters = CharacterSet.decimalDigits
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false
            }

            let currentText = authorRating.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

            if let rating = Int(newText), rating >= 1 && rating <= 10 {
                return true
            } else if newText.isEmpty { 
                return true
            }

            return false
        }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            reviewTitleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 100),
            reviewTitleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            reviewTitleLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            reviewContentLabel.topAnchor.constraint(equalTo: reviewTitleLabel.bottomAnchor, constant: 20),
            reviewContentLabel.leadingAnchor.constraint(equalTo: reviewTitleLabel.leadingAnchor),
            reviewContentLabel.trailingAnchor.constraint(equalTo: reviewTitleLabel.trailingAnchor),
            authorLabel.topAnchor.constraint(equalTo: reviewContentLabel.bottomAnchor, constant: 20),
            authorLabel.leadingAnchor.constraint(equalTo: reviewContentLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: reviewContentLabel.trailingAnchor),
            movieRatingLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 20),
            movieRatingLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            movieRatingLabel.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),
            authorRating.topAnchor.constraint(equalTo: movieRatingLabel.bottomAnchor, constant: 20),
            authorRating.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            authorRating.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),
            
            submitRatingButton.topAnchor.constraint(equalTo: authorRating.bottomAnchor, constant: 20),
            submitRatingButton.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            submitRatingButton.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor)
        ])
    }

}
