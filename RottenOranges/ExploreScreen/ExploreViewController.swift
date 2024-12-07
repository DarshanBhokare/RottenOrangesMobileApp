//
//  ExploreViewController.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/5/24.
//

import UIKit
import FirebaseFirestore

class ExploreViewController: UIViewController, UITextFieldDelegate {
    
    let exploreViewScreen = ExploreView()
    private var posts: [Post] = []
    private var filteredPosts: [Post] = []
    
    override func loadView() {
        view = exploreViewScreen
        
        reloadTableData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Explore"
        navigationItem.hidesBackButton = true
        
        exploreViewScreen.tableView.delegate = self
        exploreViewScreen.tableView.dataSource = self
        exploreViewScreen.searchBar.delegate = self

    }
    
    func reloadTableData() {
        fetchPosts { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            self?.exploreViewScreen.tableView.reloadData()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard textField == exploreViewScreen.searchBar else {
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
        exploreViewScreen.tableView.reloadData()
        
        // Show the picker view
        exploreViewScreen.tableView.isHidden = false
    }

    func hidePosts() {
        // Implement later
    }
    
    private func setupTableView() {
        exploreViewScreen.tableView.register(ExploreTableViewCell.self, forCellReuseIdentifier: "Authpost")
    }
    
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        let db = Firestore.firestore()
        var posts = [Post]()

        db.collection("posts").getDocuments { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, error == nil else {
                print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for document in querySnapshot.documents {
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
                
                dispatchGroup.enter()
                // Fetch current user's details for each post
                AuthModel().getCurrentUserDetails { userDetails, error in
                    defer {
                        dispatchGroup.leave()
                    }
                    if let error = error {
                        print("Error fetching current user details: \(error.localizedDescription)")
                        return
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(posts)
            }
        }
    }
}

extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Check if search text is empty
        if exploreViewScreen.searchBar.text?.isEmpty ?? true {
            // If search text is empty, display all posts
            return posts.count
        } else {
            // If search text is not empty, display filtered posts
            return filteredPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Authpost", for: indexPath) as! ExploreTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.post = posts[indexPath.row]
        
        // Check if search text is empty
        if exploreViewScreen.searchBar.text?.isEmpty ?? true {
            // If search text is empty, use posts array
            let post = posts[indexPath.row]
            cell.configure(with: post, at: indexPath)
        } else {
            // If search text is not empty, use filteredPosts array
            let post = filteredPosts[indexPath.row]
            cell.configure(with: post, at: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Check if search text is empty
        if exploreViewScreen.searchBar.text?.isEmpty ?? true {
            // If search text is empty, use posts array
            print(self.posts[indexPath.row])
        } else {
            // If search text is not empty, use filteredPosts array
            print(self.filteredPosts[indexPath.row])
        }
        // Perform any actions you need when a row is selected
    }
}

extension ExploreViewController: ExploreTableViewCellDelegate {
    func followButtonTapped(for post: Post) {
        // Fetch post data for the specific post
        print("Follow button tapped for post: \(post)")
        AuthModel().followPost(for: post.title) { error in
            if let error = error {
                print("Error following post: \(error.localizedDescription)")
            } else {
                print("Successfully followed post: \(post.title)")
                DispatchQueue.main.async {
                    if let visibleIndexPaths = self.exploreViewScreen.tableView.indexPathsForVisibleRows {
                        for indexPath in visibleIndexPaths {
                            let cell = self.exploreViewScreen.tableView.cellForRow(at: indexPath) as? ExploreTableViewCell
                            if let cellPost = cell?.post, cellPost.title == post.title {
                                cell?.followButton.setTitle("Following", for: .normal)
                                cell?.followButton.isEnabled = false
                                cell?.followButton.setTitleColor(.gray, for: .normal)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}
