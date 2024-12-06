//
//  NewPostView.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/5/24.
//


import UIKit

class NewPostView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Movie Name:"
        return label
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter movie name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let movieRatingTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter movie rating(1-10)"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your Review:"
        return label
    }()
    
    let contentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5
        textView.font = UIFont.systemFont(ofSize: 15)
        return textView
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
            let allowedCharacters = CharacterSet.decimalDigits
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false
            }

            let currentText = movieRatingTextField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

            if let rating = Int(newText), rating >= 1 && rating <= 10 {
                return true
            } else if newText.isEmpty {
                return true
            }

            return false
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(titleTextField)
        addSubview(contentTextView)
        addSubview(contentLabel)
        addSubview(saveButton)
        addSubview(movieRatingTextField)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            contentLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            contentLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            contentTextView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            contentTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            contentTextView.heightAnchor.constraint(equalToConstant: 150),
            
            movieRatingTextField.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 10),
            movieRatingTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            movieRatingTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            movieRatingTextField.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.topAnchor.constraint(equalTo: movieRatingTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}
