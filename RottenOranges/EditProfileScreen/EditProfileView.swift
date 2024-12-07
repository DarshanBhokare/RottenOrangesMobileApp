//
//  EditProfileView.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/7/24.
//

import UIKit
import TagListView

class EditProfileView: UIView {
    var nameField: UITextField!
    var emailField: UITextField!
    var registerBtn: UIButton!
    var imageView: UIImageView!
    var buttonTakePhoto: UIButton!
    
    var emailFieldTopConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        setupImageView()
        setupNameField()
        setupEmailField()
        setupRegisterButton()
        setupbuttonTakePhoto()
                
        initConstraints()
    }

    func setupbuttonTakePhoto(){
            buttonTakePhoto = UIButton(type: .system)
            buttonTakePhoto.setTitle("", for: .normal)
            buttonTakePhoto.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            buttonTakePhoto.contentHorizontalAlignment = .fill
            buttonTakePhoto.contentVerticalAlignment = .fill
            buttonTakePhoto.imageView?.contentMode = .scaleAspectFit
            buttonTakePhoto.showsMenuAsPrimaryAction = true
            buttonTakePhoto.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(buttonTakePhoto)
    }
    
    func setupImageView() {
            imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "logo") // Set your image here
            self.addSubview(imageView)
    }
    
    func setupNameField(){
        nameField = UITextField()
        nameField.placeholder = "Name"
        nameField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nameField)
    }
    
    
    func setupRegisterButton(){
        registerBtn = UIButton(type: .roundedRect)
        registerBtn.setTitle("Save", for: .normal)
        registerBtn.backgroundColor = .black
        registerBtn.translatesAutoresizingMaskIntoConstraints = false
        registerBtn.setTitleColor(.white, for: .normal) // Set text color to white
        registerBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(registerBtn)
    }
    
    func setupEmailField(){
        emailField = UITextField()
        emailField.placeholder = "Email"
        emailField.keyboardType = UIKeyboardType.emailAddress
        emailField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(emailField)
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
    func initConstraints(){
        
        emailFieldTopConstraint = emailField.topAnchor.constraint(equalTo: buttonTakePhoto.bottomAnchor, constant: 20)
        
        NSLayoutConstraint.activate([
            
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 1),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            
            nameField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            buttonTakePhoto.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            buttonTakePhoto.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            buttonTakePhoto.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            buttonTakePhoto.widthAnchor.constraint(equalToConstant: 100),
            buttonTakePhoto.heightAnchor.constraint(equalToConstant: 100),
            
            emailFieldTopConstraint,
            emailField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            
            registerBtn.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            registerBtn.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            registerBtn.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            registerBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
 
 
}
