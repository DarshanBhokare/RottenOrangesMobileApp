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
        feedViewScreen.searchBar.delegate=self

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
        
        // Reload the data of the picker view
        feedViewScreen.tableView.reloadData()
        
        // Show the picker view
        feedViewScreen.tableView.isHidden = false
    }

    func hidePosts() {
        // Implement later
    }
    
    private func setupTableView() {
        feedViewScreen.tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: "Authpost")
    }
    
    
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        AuthModel().getCurrentUserDetails { userDetails, error in
            guard error == nil else {
                print("Error fetching current user details: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let follows = userDetails["follows"] as? [String] ?? []
            
            if follows.isEmpty {
                // If follows array is empty, call the completion handler with an empty array
                completion([])
                return
            }
            
            let db = Firestore.firestore()
            var posts = [Post]()
            
            // Fetch posts where the title is in the follows list
            db.collection("posts").whereField("title", in: follows).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let content = data["content"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let imageUrl = data["image"] as? String ?? ""
                    let tags = data["tags"] as? [String] ?? []
                    let author = data["author"] as? String ?? ""
                    let rating = data["rating"] as? Double ?? 0.0
                    
                    let post = Post(title: title, content: content, timestamp: timestamp, image: imageUrl, tags:tags, author:author, rating: rating)
                    posts.append(post)
                }
                
                completion(posts)
            }
        }
    }

}

extension FeedViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if feedViewScreen.searchBar.text?.isEmpty ?? true{
            return posts.count
        }
        else{
            return filteredPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Authpost", for: indexPath) as! FeedTableViewCell
        
        // Determine whether to use posts or filteredPosts
        let post = (feedViewScreen.searchBar.text?.isEmpty ?? true) ? posts[indexPath.row] : filteredPosts[indexPath.row]
        
        // Fetch the user by post.author
        AuthModel().getUserByUsername(username: post.author) { userDetails, documentId, error in
            if let error = error {
                // Handle error (e.g., log it or display an alert)
                print("Error fetching user details for author \(post.author): \(error.localizedDescription)")
                // Configure the cell with the post only
                DispatchQueue.main.async {
                    cell.configure(with: post, author: nil, at: indexPath)
                }
            } else if let userDetails = userDetails {
                // Pass the user details to the configure method
                DispatchQueue.main.async {
                    cell.configure(with: post, author: userDetails, at: indexPath)
                }
            }
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print(self.posts[indexPath.row]);
        
        if feedViewScreen.searchBar.text?.isEmpty ?? true {
            // If search text is empty, use posts array
            displayReview(review: posts[indexPath.row])
        } else {
            // If search text is not empty, use filteredPosts array
            displayReview(review: filteredPosts[indexPath.row])
        }

    }
    
    private func displayReview(review: Post) {
        let showReviewController = ShowReviewViewController(review: review)
        self.navigationController?.pushViewController(showReviewController, animated: true)
    }
}
