//
//  HomeView.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import UIKit

class HomeView: UIView {

    var loginBtn: UIButton!
    var registerBtn: UIButton!
    var imageView: UIImageView!
    var tableView: UITableView!
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.backgroundColor = .white
            
            setupImageView()
            setupLoginButton()
            setupRegisterButton()
            setupTableView()
            
            
            initConstraints()
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
    func setupImageView() {
            imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "logo")
            self.addSubview(imageView)
    }
    
    func setupTableView() {
            tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tableView)
            
        tableView.register(ExploreTableViewCell.self, forCellReuseIdentifier: "Authpost")
    }
    
    
    func setupLoginButton(){
            loginBtn = UIButton(type: .roundedRect)
            loginBtn.setTitle("Login", for: .normal)
            loginBtn.backgroundColor = .blue
            loginBtn.translatesAutoresizingMaskIntoConstraints = false
            loginBtn.setTitleColor(.white, for: .normal)
            loginBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            self.addSubview(loginBtn)
    }
        
    func setupRegisterButton(){
            registerBtn = UIButton(type: .roundedRect)
            registerBtn.setTitle("Register", for: .normal)
            registerBtn.backgroundColor = .black
            registerBtn.translatesAutoresizingMaskIntoConstraints = false
            registerBtn.setTitleColor(.white, for: .normal)
            registerBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            self.addSubview(registerBtn)
    }

    
    func initConstraints() {
           NSLayoutConstraint.activate([
         
               imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
               imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 1),
               imageView.widthAnchor.constraint(equalToConstant: 100),
               imageView.heightAnchor.constraint(equalToConstant: 100),
               
               loginBtn.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
               registerBtn.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
               loginBtn.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
               registerBtn.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
               loginBtn.widthAnchor.constraint(equalToConstant: 100),
               loginBtn.heightAnchor.constraint(equalToConstant: 30),
               registerBtn.widthAnchor.constraint(equalToConstant: 100),
               registerBtn.heightAnchor.constraint(equalToConstant: 30),
               
               tableView.topAnchor.constraint(equalTo: loginBtn.bottomAnchor, constant: 20),
               tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
               tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
               tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
           ])
    }

}
