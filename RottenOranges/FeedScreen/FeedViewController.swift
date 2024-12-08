//
//  FeedViewController.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/5/24.
//

import UIKit
import FirebaseFirestore

class FeedViewController: UIViewController, UITextFieldDelegate {
    
    let feedViewScreen = FeedView()
    
    private var posts: [Post] = []
    private var filteredPosts: [Post] = []
    
    override func loadView() {
        view = feedViewScreen
        reloadTableData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feed"
        navigationItem.hidesBackButton = true
        
        feedViewScreen.tableView.delegate = self
        feedViewScreen.tableView.dataSource = self
        feedViewScreen.searchBar.delegate = self
    }
    
    func reloadTableData() {
        fetchPosts { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            self?.feedViewScreen.tableView.reloadData()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == feedViewScreen.searchBar else {
            return true
        }

        // Calculate the new text after the replacement
        let currentText = textField.text ?? ""
        guard let newTextRange = Range(range, in: currentText) else {
            return true
        }
        let newText = currentText.replacingCharacters(in: newTextRange, with: string)
        
        // Show or hide suggestions based on the new text
        if !newText.isEmpty {
            showPosts(for: newText)
        } else {
            hidePosts()
        }

        return true
    }
    
    func showPosts(for text: String) {
        filteredPosts = posts.filter { post in
            // Check if any tag starts with the search text
            let matchesTags = post.tags.contains { $0.lowercased().starts(with: text.lowercased()) }
            // Check if the title contains the search text
            let matchesTitle = post.title.lowercased().contains(text.lowercased())
            
            // Return true if either condition is true
            return matchesTags || matchesTitle
        }
        
        feedViewScreen.tableView.reloadData()
        feedViewScreen.tableView.isHidden = false
    }

    func hidePosts() {
        // Implement later
    }
    
    private func setupTableView() {
        feedViewScreen.tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: "Authpost")
    }
    
    // Fetch posts based on followed authors
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        AuthModel().getCurrentUserDetails { userDetails, error in
            guard error == nil else {
                print("Error fetching current user details: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            guard let follows = userDetails["follows"] as? [DocumentReference], !follows.isEmpty else {
                completion([]) // No follows, return empty array
                return
            }
            
            let db = Firestore.firestore()
            var posts = [Post]()
            let group = DispatchGroup()
            
            // Fetch posts for each followed author
            for authorRef in follows {
                group.enter()
                db.collection("posts").whereField("authorRef", isEqualTo: authorRef).getDocuments { querySnapshot, error in
                    if let error = error {
                        print("Error fetching posts for author \(authorRef.path): \(error.localizedDescription)")
                        group.leave()
                        return
                    }
                    
                    for document in querySnapshot?.documents ?? [] {
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let content = data["content"] as? String ?? ""
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        let imageUrl = data["image"] as? String ?? ""
                        let tags = data["tags"] as? [String] ?? []
                        let author = data["author"] as? String ?? ""
                        guard let authorRef = data["authorRef"] as? DocumentReference else {
                            print("Skipping post '\(title)' due to missing authorRef.")
                            continue
                        }
                        let rating = data["rating"] as? Double ?? 0.0
                        
                        let post = Post(
                            title: title,
                            content: content,
                            timestamp: timestamp,
                            image: imageUrl,
                            tags: tags,
                            author: author,
                            authorRef: authorRef,
                            rating: rating
                        )
                        posts.append(post)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(posts)
            }
        }
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if feedViewScreen.searchBar.text?.isEmpty ?? true {
            return posts.count
        } else {
            return filteredPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Authpost", for: indexPath) as! FeedTableViewCell
        
        // Determine whether to use posts or filteredPosts
        let post = (feedViewScreen.searchBar.text?.isEmpty ?? true) ? posts[indexPath.row] : filteredPosts[indexPath.row]
        
        // Fetch the user by post.authorRef
        post.authorRef.getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching author details for \(post.author): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    cell.configure(with: post, author: nil, at: indexPath)
                }
            } else if let data = documentSnapshot?.data() {
                DispatchQueue.main.async {
                    cell.configure(with: post, author: data, at: indexPath)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = (feedViewScreen.searchBar.text?.isEmpty ?? true) ? posts[indexPath.row] : filteredPosts[indexPath.row]
        displayReview(review: selectedPost)
    }
    
    private func displayReview(review: Post) {
        let showReviewController = ShowReviewViewController(review: review)
        self.navigationController?.pushViewController(showReviewController, animated: true)
    }
}
