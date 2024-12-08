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
//        print("Current data before fetched \(self.posts)")
//        self.initSetup()
//        print("Current data after fetched \(self.posts)")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Explore"
        navigationItem.hidesBackButton = true
        
        
        
        //        exploreViewScreen.tableView.delegate = self
        //        exploreViewScreen.tableView.dataSource = self
        //        exploreViewScreen.searchBar.delegate = self
        
        //        initSetup()
        
        setupTableView()
        
        fetchPosts { [weak self] fetchedPosts in
        guard let self = self else { return }
        self.posts = fetchedPosts
        DispatchQueue.main.async {
            self.exploreViewScreen.tableView.reloadData()
        }
        }
        
       
            
        }
    
    
    func initSetup()
    {
        self.reloadTableData()
        
        exploreViewScreen.tableView.reloadData()
        
        exploreViewScreen.tableView.delegate = self
        exploreViewScreen.tableView.dataSource = self
        exploreViewScreen.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure table view delegate and data source are reassigned
        
        initSetup()
    }
    
    func reloadTableData() {
        print("Fetching")
        if !posts.isEmpty
        {
            print("Posts in reload data are \(posts)")
            self.exploreViewScreen.tableView.reloadData()
            return
        }
        
        fetchPosts { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            self?.exploreViewScreen.tableView.reloadData()
        }
        print("Current data after second fetched \(posts)")
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
        // Enable dynamic row height
        exploreViewScreen.tableView.rowHeight = UITableView.automaticDimension
           
        // Set an estimated row height (optional, helps with performance)
        exploreViewScreen.tableView.estimatedRowHeight = 150
    }
    
    
//    private var isFetchingPosts = false
    
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        // Ensure we don't fetch multiple times simultaneously
//        guard !isFetchingPosts else { return }
//        isFetchingPosts = true
        
        let db = Firestore.firestore()
        var posts = [Post]()
        
        let group = DispatchGroup()
        group.enter()
        
        db.collection("posts").order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
//            self.isFetchingPosts = false
            //print("Querysnapshot \(querySnapshot)")
//            guard let querySnapshot = querySnapshot, error == nil else {
//                print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
//                completion([])
//                group.leave()
//                return
//            }
            
            if let error = error {
                print("Error fetching posts \(error.localizedDescription)")
                group.leave()
                return
            }
            
            //print("Documents \(querySnapshot?.documents)")
            
            for document in querySnapshot?.documents ?? [] {
                
                let data = document.data()
                let title = data["title"] as? String ?? ""
                let content = data["content"] as? String ?? ""
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let imageUrl = data["image"] as? String ?? ""
                let tags = data["tags"] as? [String] ?? []
                let author = data["author"] as? String ?? ""
                let rating = data["rating"] as? Double ?? 0.0
                guard let authorRef = data["authorRef"] as? DocumentReference else {
                    print("Skipping post '\(title)' due to missing authorRef.")
                    continue
                }
                
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
                
                //print("Post \(post)")
                
                posts.append(post)
            }
            group.leave()
            
            print("Posts in fetch \(posts)")
            
            // Sort posts (Firestore already supports ordering by timestamp, but for clarity)
            posts.sort { $0.timestamp > $1.timestamp }
            self.reloadTableData()
            
            group.notify(queue: .main) {
                completion(posts)
            }
            // Return the fetched posts
//            completion(posts)
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
        
        // Determine whether to use posts or filteredPosts
        let post = (exploreViewScreen.searchBar.text?.isEmpty ?? true) ? posts[indexPath.row] : filteredPosts[indexPath.row]
        cell.post = post
        
        // Fetch the user by post.author
//        AuthModel().getUserByDocumentReference(userRef: post.authorRef) { userDetails, documentId, error in
//            if let error = error {
//                print("Error fetching user details for author \(post.author): \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    cell.configure(with: post, author: nil, at: indexPath)
//                }
//            } else if let userDetails = userDetails {
//                DispatchQueue.main.async {
//                    cell.configure(with: post, author: userDetails, at: indexPath)
//                }
//            }
//        }
        
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

        // Check if search text is empty
        if exploreViewScreen.searchBar.text?.isEmpty ?? true {
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

extension ExploreViewController: ExploreTableViewCellDelegate {
    func followButtonTapped(for post: Post) {
        // Fetch post data for the specific post
        print("Follow button tapped for post: \(post)")
        
        guard let visibleIndexPaths = self.exploreViewScreen.tableView.indexPathsForVisibleRows else { return }
        
        for indexPath in visibleIndexPaths {
            if let cell = self.exploreViewScreen.tableView.cellForRow(at: indexPath) as? ExploreTableViewCell,
               let cellPost = cell.post, cellPost.title == post.title {
                
                let buttonTitle = cell.followButton.title(for: .normal)
                
                if buttonTitle == "Unfollow" {
                    // Call the unfollowUser method
                    AuthModel().unfollowUser(for: post.authorRef) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                // Show an alert for the error
                                self.showAlert(message: "Error unfollowing reviewer: \(error.localizedDescription)")
                                print("Error unfollowing reviewer: \(error.localizedDescription)")
                            } else {
                                // Update the button to "Follow" and enable it
                                cell.followButton.setTitle("Follow", for: .normal)
                                cell.followButton.isEnabled = true
                                cell.followButton.setTitleColor(.systemBlue, for: .normal)
                                self.showAlert(message: "Successfully unfollowed reviewer: \(post.author)")
                                print("Successfully unfollowed reviewer: \(post.author)")
                            }
                        }
                    }
                } else {
                    // Call the followUser method
                    AuthModel().followUser(for: post.authorRef) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                // Show an alert for the error
                                self.showAlert(message: "Error following reviewer: \(error.localizedDescription)")
                                print("Error following reviewer: \(error.localizedDescription)")
                            } else {
                                // Update the button to "Following" and disable it
                                cell.followButton.setTitle("Unfollow", for: .normal)
                                cell.followButton.isEnabled = false
                                cell.followButton.setTitleColor(.gray, for: .normal)
                                self.showAlert(message: "Successfully followed reviewer: \(post.author)")
                                print("Successfully followed reviewer: \(post.author)")
                            }
                        }
                    }
                }
                
                break
            }
        }
    }



    // Show alert helper function
    private func showAlert(message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }

}
