//
//  RegisterView.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import UIKit
import TagListView

class RegisterView: UIView {
    var nameField: UITextField!
    var emailField: UITextField!
    var passwordField: UITextField!
    var confirmPasswordField: UITextField!
    var registerBtn: UIButton!
    var imageView: UIImageView!
    var buttonSelectRoleType: UIButton!
    var buttonTakePhoto: UIButton!
    
    var expertiseField: UITextField!
    var addExpertiseButton: UIButton!
    var expertiseTagsView: TagListView!
    var suggestionsPickerView: UIPickerView!
    
    var roleLabel: UILabel!
    
    var emailFieldTopConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        setupImageView()
        setupNameField()
        setupEmailField()
        setupPasswordField()
        setupConfirmPasswordField()
        setupRegisterButton()
        setupbuttonTakePhoto()
        setupbuttonSelectRoleType()
        setupRoleLabel()
        setupSuggestionsPickerView()
        setupExpertiseField()
        setupExpertiseTagsView()
        setupAddExpertiseButton()
        
        
        initConstraints()
    }
    
    func setupSuggestionsPickerView() {
        suggestionsPickerView = UIPickerView()
        suggestionsPickerView.translatesAutoresizingMaskIntoConstraints = false
        suggestionsPickerView.isUserInteractionEnabled = true
        self.addSubview(suggestionsPickerView)
    }
    
    func showExpertiseTagComponents(_ show: Bool) {
            let alpha: CGFloat = show ? 1.0 : 0.0
            
            UIView.animate(withDuration: 0.1) {
                self.expertiseField.alpha = alpha
                self.addExpertiseButton.alpha = alpha
                self.expertiseTagsView.alpha = alpha
            }
    }
    
    func setupExpertiseField() {
            expertiseField = UITextField()
            expertiseField.placeholder = "Enter expertise area"
            expertiseField.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(expertiseField)
    }

    func setupAddExpertiseButton() {
            addExpertiseButton = UIButton(type: .system)
            addExpertiseButton.setTitle("Add", for: .normal)
            addExpertiseButton.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(addExpertiseButton)
    }

    func setupExpertiseTagsView() {
            expertiseTagsView = TagListView()
            expertiseTagsView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(expertiseTagsView)
    }
    

    
    func setupRoleLabel(){
        roleLabel = UILabel()
        roleLabel.text = "Select Role : "
        roleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(roleLabel)
    }
    
    func setupbuttonSelectRoleType(){
        buttonSelectRoleType = UIButton(type: .system)
        buttonSelectRoleType.setTitle("User", for: .normal)
        buttonSelectRoleType.showsMenuAsPrimaryAction = true
        buttonSelectRoleType.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonSelectRoleType)
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
    
    func setupPasswordField(){
        passwordField = UITextField()
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(passwordField)
    }
    
    func setupConfirmPasswordField(){
        confirmPasswordField=UITextField()
        confirmPasswordField.placeholder = "Confirm Password"
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(confirmPasswordField)
        
    }
    
    func setupNameField(){
        nameField = UITextField()
        nameField.placeholder = "Name"
        nameField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nameField)
    }
    
    
    func setupRegisterButton(){
        registerBtn = UIButton(type: .roundedRect)
        registerBtn.setTitle("Register", for: .normal)
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
    
    func updatePickerVisibility(isVisible: Bool){
        suggestionsPickerView.isHidden = !isVisible
        
        emailFieldTopConstraint.constant = isVisible ? 120 : 20
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    
    func initConstraints(){
        
        emailFieldTopConstraint = emailField.topAnchor.constraint(equalTo: expertiseTagsView.bottomAnchor, constant: 20)
        
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
            
            
            roleLabel.topAnchor.constraint(equalTo: buttonTakePhoto.bottomAnchor, constant: 20),
            roleLabel.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            roleLabel.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            
            
            buttonSelectRoleType.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 20),
            buttonSelectRoleType.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            buttonSelectRoleType.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            
            expertiseField.topAnchor.constraint(equalTo: buttonSelectRoleType.bottomAnchor, constant: 20),
            expertiseField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            expertiseField.trailingAnchor.constraint(equalTo: addExpertiseButton.leadingAnchor, constant: -8),
            expertiseField.heightAnchor.constraint(equalToConstant: 40),
            
            suggestionsPickerView.topAnchor.constraint(equalTo: expertiseField.bottomAnchor, constant: -50),
            suggestionsPickerView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            suggestionsPickerView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                        
            addExpertiseButton.centerYAnchor.constraint(equalTo: expertiseField.centerYAnchor),
            addExpertiseButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),

                        
            expertiseTagsView.topAnchor.constraint(equalTo: expertiseField.bottomAnchor, constant: 8),
            expertiseTagsView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            expertiseTagsView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            
            emailFieldTopConstraint,
            emailField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            
            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            confirmPasswordField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            
            registerBtn.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 20),
            registerBtn.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            registerBtn.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            registerBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
 
 
}
