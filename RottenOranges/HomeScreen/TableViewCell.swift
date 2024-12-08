//
//  TableViewCell.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol ExploreTableViewCellDelegate: AnyObject {
    func followButtonTapped(for post: Post)
}

class ExploreTableViewCell: UITableViewCell {
    var wrapperCellView: UIView!
    var labelTitle: UILabel!
    var followButton: UIButton!
    var labelTimestamp: UILabel!
    var labelTags: UILabel!
    var createdByLabel: UILabel!
    var imageProfile: UIImageView!
    var authorRating: UILabel!
    
    weak var delegate: ExploreTableViewCellDelegate?
    var indexPath: IndexPath?
    var post: Post?
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWrapperCellView()
        setupLabels()
        setupFollowButton()
        setupImageProfile()
        if Auth.auth().currentUser != nil {
            initConstraints()
        } else{
            initConstraintsUnAuth()
        }
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWrapperCellView() {
        wrapperCellView = UIView()
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrapperCellView)
    }

    func setupLabels() {
        labelTitle = UILabel()
        labelTitle.font = UIFont.boldSystemFont(ofSize: 16)
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelTitle)

        followButton = UIButton(type: .system)
        followButton.setTitle("Follow", for: .normal)
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        followButton.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(followButton)
        
        labelTags = UILabel()
        labelTags.font = UIFont.systemFont(ofSize: 13)
        labelTags.textColor = .systemGreen
        labelTags.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelTags)

        labelTimestamp = UILabel()
        labelTimestamp.font = UIFont.systemFont(ofSize: 12)
        labelTimestamp.textColor = .gray
        labelTimestamp.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelTimestamp)

        createdByLabel = UILabel()
        createdByLabel.font = UIFont.systemFont(ofSize: 12)
        createdByLabel.textColor = .gray
        createdByLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(createdByLabel)
        
        authorRating = UILabel()
        authorRating.font = UIFont.systemFont(ofSize: 12)
        authorRating.textColor = .gray
        authorRating.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(authorRating)
    }

    func setupFollowButton() {
        // Set the button style
        let image = UIImage(systemName: "person.crop.circle.fill.badge.plus")
        followButton.setImage(image, for: .normal)
        followButton.tintColor = .blue

        followButton.layer.cornerRadius = 5
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.blue.cgColor

        // Add button action
        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }


    func setupImageProfile() {
        imageProfile = UIImageView()
        imageProfile.contentMode = .scaleAspectFill
        imageProfile.clipsToBounds = true
        imageProfile.layer.cornerRadius = 8
        imageProfile.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(imageProfile)
    }

    func initConstraints() {
        
        NSLayoutConstraint.activate([
                wrapperCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                wrapperCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                wrapperCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                wrapperCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

                labelTitle.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 12),
                labelTitle.leadingAnchor.constraint(equalTo: imageProfile.trailingAnchor, constant: 64),
                labelTitle.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),

                followButton.topAnchor.constraint(equalTo: labelTimestamp.bottomAnchor, constant: 8),
                followButton.bottomAnchor.constraint(equalTo: wrapperCellView.bottomAnchor, constant: -8),
                followButton.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                followButton.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),

                imageProfile.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 8),
                imageProfile.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                imageProfile.widthAnchor.constraint(equalToConstant: 100), // Restrict width
                imageProfile.heightAnchor.constraint(equalToConstant: 100), // Restrict height


                labelTags.topAnchor.constraint(equalTo: imageProfile.bottomAnchor, constant: 8),
                labelTags.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                labelTags.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
                
                labelTimestamp.topAnchor.constraint(equalTo: labelTags.bottomAnchor, constant: 8),
                labelTimestamp.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                labelTimestamp.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),

                authorRating.topAnchor.constraint(equalTo: followButton.topAnchor, constant: -44),
                authorRating.bottomAnchor.constraint(equalTo: followButton.topAnchor, constant: -22),
                authorRating.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
                
                createdByLabel.topAnchor.constraint(equalTo: followButton.topAnchor, constant: -32),
                createdByLabel.bottomAnchor.constraint(equalTo: followButton.topAnchor, constant: -10),
                createdByLabel.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16)
            ])
    }
    
    func initConstraintsUnAuth() {
        
        NSLayoutConstraint.activate([
                wrapperCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                wrapperCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                wrapperCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                wrapperCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

                labelTitle.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 12),
                labelTitle.leadingAnchor.constraint(equalTo: imageProfile.trailingAnchor, constant: 64),
                labelTitle.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),

                followButton.topAnchor.constraint(equalTo: labelTimestamp.bottomAnchor, constant: 8),
                followButton.bottomAnchor.constraint(equalTo: wrapperCellView.bottomAnchor, constant: -8),
                followButton.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                followButton.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),

                imageProfile.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 8),
                imageProfile.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                imageProfile.widthAnchor.constraint(equalToConstant: 100), // Restrict width
                imageProfile.heightAnchor.constraint(equalToConstant: 100), // Restrict height


                labelTags.topAnchor.constraint(equalTo: imageProfile.bottomAnchor, constant: 8),
                labelTags.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                labelTags.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
                
                labelTimestamp.topAnchor.constraint(equalTo: labelTags.bottomAnchor, constant: 8),
                labelTimestamp.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                labelTimestamp.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),

                authorRating.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 12),
                //authorRating.bottomAnchor.constraint(equalTo: followButton.topAnchor, constant: -22),
                authorRating.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
                
                createdByLabel.topAnchor.constraint(equalTo: authorRating.bottomAnchor, constant: 12),
                //createdByLabel.bottomAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: -10),
                createdByLabel.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16)
            ])
    }
    
    @objc func followButtonTapped() {
        
        if let post = post {
            delegate?.followButtonTapped(for: post)
        }
    }

    func configure(with post: Post, author: [String: Any]? = nil, at indexPath: IndexPath) {
        self.labelTitle.text = post.title
        self.labelTimestamp.text = formatDate(post.timestamp)
        self.labelTags.text = post.tags.joined(separator: ", ")
        self.followButton.isHidden = false
        if let author = author {
            self.createdByLabel.text = "Created By \(author["name"] as? String ?? "Unknown Author")"
            if let rating = author["rating"] as? Double {
                self.authorRating.text = "Author's Reputation: \(rating)/10.0"
            } else {
                self.authorRating.text = "Author's Reputation: Not Available"
            }
        } else {
            self.createdByLabel.text = "Created By Unknown Author"
            self.authorRating.text = "Author's Reputation: Not Available"
        }
        
        if let imageUrl = URL(string: post.image) {
            self.loadImage(from: imageUrl)
        } else {
            self.imageProfile.image = UIImage(systemName: "person")
        }
        
        // Check if the user is signed in
        if let currentUser = Auth.auth().currentUser {
            // User is signed in, configure the follow button
            followButton.isHidden = false
            followButton.isEnabled = true
            
            AuthModel().getCurrentUserDetails { userDetails, error in
                if let error = error {
                    print("Error fetching current user details: \(error.localizedDescription)")
                    return
                }
                
                guard let follows = userDetails["follows"] as? [DocumentReference] else {
                    print("No follows found or invalid format")
                    return
                }
                
                DispatchQueue.main.async {
                    if follows.contains(post.authorRef) {
                        self.followButton.setTitle("Following", for: .normal)
                        self.followButton.isEnabled = false // Disable the button
                        self.followButton.setTitleColor(.gray, for: .normal)
                    } else {
                        self.followButton.setTitle("Follow", for: .normal)
                        self.followButton.isEnabled = true // Enable the button
                        self.followButton.setTitleColor(.blue, for: .normal)
                    }
                }
            }
        } else {
            // User is not signed in, remove follow button from the layout
            followButton.isHidden = true
            followButton.removeFromSuperview()
        }
    }



    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                // Set default image if loading fails
                DispatchQueue.main.async {
                    self?.imageProfile.image = UIImage(systemName: "person")
                }
                return
            }
            DispatchQueue.main.async {
                // Set image from data
                self?.imageProfile.image = UIImage(data: data)
            }
        }
        task.resume()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: date)
    }
}


class FeedTableViewCell: UITableViewCell {
    var wrapperCellView: UIView!
    var labelTitle: UILabel!
    var unfollowButton: UIButton!
    var labelTags: UILabel!
    var labelTimestamp: UILabel!
    var createdByLabel: UILabel!
    var imageProfile: UIImageView!
    
    var authorRating: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWrapperCellView()
        setupLabels()
        setupUnfollowButton()
        setupImageProfile()
        initConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWrapperCellView() {
        wrapperCellView = UIView()
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrapperCellView)
    }

    func setupLabels() {
        labelTitle = UILabel()
        labelTitle.font = UIFont.boldSystemFont(ofSize: 16)
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelTitle)

        unfollowButton = UIButton(type: .system)
        unfollowButton.setTitle("Unfollow", for: .normal)
        unfollowButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        unfollowButton.translatesAutoresizingMaskIntoConstraints = false
        
        labelTags = UILabel()
        labelTags.font = UIFont.systemFont(ofSize: 13)
        labelTags.textColor = .systemGreen
        labelTags.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelTags)

        labelTimestamp = UILabel()
        labelTimestamp.font = UIFont.systemFont(ofSize: 12)
        labelTimestamp.textColor = .gray
        labelTimestamp.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelTimestamp)

        createdByLabel = UILabel()
        createdByLabel.font = UIFont.systemFont(ofSize: 12)
        createdByLabel.textColor = .gray
        createdByLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(createdByLabel)
        
        authorRating = UILabel()
        authorRating.font = UIFont.systemFont(ofSize: 12)
        authorRating.textColor = .gray
        authorRating.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(authorRating)
    }

    func setupUnfollowButton() {
        unfollowButton.layer.cornerRadius = 5
        unfollowButton.layer.borderWidth = 1
        unfollowButton.layer.borderColor = UIColor.blue.cgColor
    }

    func setupImageProfile() {
        imageProfile = UIImageView()
        imageProfile.contentMode = .scaleAspectFill
        imageProfile.clipsToBounds = true
        imageProfile.layer.cornerRadius = 8
        imageProfile.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(imageProfile)
    }

    func initConstraints() {
        NSLayoutConstraint.activate([
                wrapperCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                wrapperCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                wrapperCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                wrapperCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

                labelTitle.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 12),
                labelTitle.leadingAnchor.constraint(equalTo: imageProfile.trailingAnchor, constant: 64),
                labelTitle.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),

                imageProfile.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 8),
                imageProfile.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                imageProfile.widthAnchor.constraint(equalToConstant: 100),
                imageProfile.heightAnchor.constraint(equalToConstant: 100),
                
                labelTags.topAnchor.constraint(equalTo: imageProfile.bottomAnchor, constant: 8),
                labelTags.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                labelTags.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),

                labelTimestamp.topAnchor.constraint(equalTo: labelTags.bottomAnchor, constant: 8),
                labelTimestamp.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
                labelTimestamp.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
                
                

                createdByLabel.topAnchor.constraint(equalTo: labelTimestamp.bottomAnchor, constant: 12),
                createdByLabel.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
                createdByLabel.bottomAnchor.constraint(equalTo: wrapperCellView.bottomAnchor, constant: -16),
                
                authorRating.topAnchor.constraint(equalTo: createdByLabel.topAnchor, constant: 10),
                authorRating.bottomAnchor.constraint(equalTo: wrapperCellView.bottomAnchor, constant: -8),
                authorRating.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
            ])
    }

    func configure(with post: Post, author: [String: Any]? = nil, at indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.labelTitle.text = post.title
            self.labelTimestamp.text = self.formatDate(post.timestamp)
            self.labelTags.text = post.tags.joined(separator: ", ")
            
            if let author = author {
                self.createdByLabel.text = "Created By \(author["name"] as? String ?? "Unknown Author")"
                if let rating = author["rating"] as? Double {
                    self.authorRating.text = "Author's Reputation: \(rating)/10.0"
                } else {
                    self.authorRating.text = "Author's Reputation: Not Available"
                }
            } else {
                self.createdByLabel.text = "Created By Unknown Author"
                self.authorRating.text = "Author's Reputation: Not Available"
            }
            
            if let imageUrl = URL(string: post.image) {
                self.loadImage(from: imageUrl)
            } else {
                self.imageProfile.image = UIImage(systemName: "person")
            }
        }
    }


    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                // Set default image if loading fails
                DispatchQueue.main.async {
                    self?.imageProfile.image = UIImage(systemName: "person")
                }
                return
            }
            DispatchQueue.main.async {
                // Set image from data
                self?.imageProfile.image = UIImage(data: data)
            }
        }
        task.resume()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: date)
    }
}
