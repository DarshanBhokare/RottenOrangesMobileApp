//
//  ShowProfileView.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import UIKit

class ShowProfileView: UIView {

    var imageProfile: UIImageView!
    var labelName: UILabel!
    var labelEmail: UILabel!
    var labelRole: UILabel!
    var labelTags: UILabel!
    var labelAddressHeading: UILabel!
    var labelAddress1: UILabel!
    var labelAddress2: UILabel!
    var labelZip: UILabel!
    var buttonEdit: UIButton!
    var buttonLogout: UIButton!
    var labelRating: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
            
        setupImageProfile()
        setupLabelName()
        setupLabelEmail()
        setupLabelRole()
        setupLabelTags()
        setupbuttonLogout()
        setupLabelRating()
        initConstraints()
    }
    
    func setupbuttonLogout(){
        buttonLogout = UIButton(type: .system)
        buttonLogout.setTitle("Logout", for: .normal)
        buttonLogout.setTitleColor(.systemRed, for: .normal)
        buttonLogout.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonLogout)
    }
    
    func setupbuttonEdit(){
        buttonEdit = UIButton(type: .system)
        buttonEdit.setTitle("Edit Profile", for: .normal)
        buttonEdit.setTitleColor(.systemBlue, for: .normal)
        buttonEdit.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonEdit)
    }
    
    func setupImageProfile(){
        imageProfile = UIImageView()
        imageProfile.image = UIImage(systemName: "person.fill")
        imageProfile.tintColor = .black
        imageProfile.contentMode = .scaleToFill
        imageProfile.clipsToBounds = true
        imageProfile.layer.cornerRadius = 10
        imageProfile.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageProfile)
    }
    
    func setupLabelName(){
        labelName = UILabel()
        labelName.textColor = .black
        labelName.font = UIFont.boldSystemFont(ofSize: 26)
        labelName.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelName)
    }
    
    func setupLabelRating(){
        labelRating = UILabel()
        labelRating.textColor = .black
        labelRating.font = UIFont.boldSystemFont(ofSize: 26)
        labelRating.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelRating)
    }
    
    func setupLabelEmail(){
        labelEmail = UILabel()
        labelEmail.textColor = .black
        labelEmail.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelEmail)
    }
    
    func setupLabelRole(){
        labelRole = UILabel()
        labelRole.textColor = .black
        labelRole.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelRole)
    }
    
    func setupLabelTags(){
        labelTags = UILabel()
        labelTags.textColor = .black
        labelTags.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelTags)
    }
    
    func setupLabelAddressHeading(){
        labelAddressHeading = UILabel()
        labelAddressHeading.textColor = .black
        labelAddressHeading.font = UIFont.boldSystemFont(ofSize: 18)
        labelAddressHeading.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelAddressHeading)
    }
    
    func setupLabelAddress1(){
        labelAddress1 = UILabel()
        labelAddress1.textColor = .black
        labelAddress1.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelAddress1)
    }
    
    func setupLabelAddress2(){
        labelAddress2 = UILabel()
        labelAddress2.textColor = .black
        labelAddress2.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelAddress2)
    }
    
    func setupLabelZip(){
        labelZip = UILabel()
        labelZip.textColor = .black
        labelZip.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelZip)
    }
        
    func initConstraints(){
        NSLayoutConstraint.activate([
            imageProfile.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            imageProfile.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 48),
            imageProfile.widthAnchor.constraint(equalToConstant: 100),
            imageProfile.heightAnchor.constraint(equalToConstant: 100),
            
            labelName.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            labelName.topAnchor.constraint(equalTo: imageProfile.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            
            labelEmail.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            labelEmail.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 28),
            
            labelRole.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            labelRole.topAnchor.constraint(equalTo: labelEmail.bottomAnchor, constant: 16),
            
            labelRating.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            labelRating.topAnchor.constraint(equalTo: labelRole.bottomAnchor, constant: 16),
            
            labelTags.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            labelTags.topAnchor.constraint(equalTo: labelRating.bottomAnchor, constant: 16),
            
            buttonLogout.topAnchor.constraint(equalTo: labelTags.bottomAnchor, constant: 80),
            buttonLogout.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

