//
//  FeedView.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/5/24.
//

import UIKit

class FeedView: UIView {
    
    var imageView: UIImageView!
    var tableView: UITableView!
    var profileBtn: UIButton!
    var searchBar: UITextField!

    
    override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.backgroundColor = .white
            setupTableView()
            setUpSearchBar()
            initConstraints()
        
    }
    
    required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpSearchBar(){
        searchBar = UITextField()
        searchBar.placeholder = "Search Review"
        searchBar.borderStyle = .roundedRect
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(searchBar)
    }

    
    func setupTableView() {
            tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tableView)
            
            tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: "Authpost")
    }


    
    func initConstraints() {
        let tabBarHeight: CGFloat = 24 
        
        NSLayoutConstraint.activate([
            // Search bar constraints
            searchBar.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 30),
            searchBar.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            // Table view constraints
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -tabBarHeight)
        ])
    }

}
