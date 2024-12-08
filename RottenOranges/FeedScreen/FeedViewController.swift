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
    private var isDataLoaded = false
    
    override func loadView() {
        view = feedViewScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feed"
        navigationItem.hidesBackButton = true
        
        
        setupTableView()
        
        self.reloadTableData()
        
        feedViewScreen.tableView.reloadData()
        
        feedViewScreen.tableView.delegate = self
        feedViewScreen.tableView.dataSource = self
        feedViewScreen.searchBar.delegate = self
        
       
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts { [weak self] fetchedPosts in
            guard let self = self else { return }
            self.posts = fetchedPosts

           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.feedViewScreen.tableView.reloadData()
            }
        }
    }
    
    func reloadTableData() {
        guard !isDataLoaded else { return } // Avoid reloading if data is already loaded
        fetchPosts { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            self?.isDataLoaded = true
            DispatchQueue.main.async {
                self?.feedViewScreen.tableView.reloadData()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == feedViewScreen.searchBar else {
            return true
        }

        let currentText = textField.text ?? ""
        guard let newTextRange = Range(range, in: currentText) else {
            return true
        }
        let newText = currentText.replacingCharacters(in: newTextRange, with: string)
        
        if !newText.isEmpty {
            showPosts(for: newText)
        } else {
            hidePosts()
        }

        return true
    }
    
    func showPosts(for text: String) {
        filteredPosts = posts.filter { post in
            let matchesTags = post.tags.contains { $0.lowercased().starts(with: text.lowercased()) }
            let matchesTitle = post.title.lowercased().contains(text.lowercased())
            return matchesTags || matchesTitle
        }
        
        feedViewScreen.tableView.reloadData()
        feedViewScreen.tableView.isHidden = false
    }

    func hidePosts() {
        filteredPosts.removeAll()
        feedViewScreen.tableView.reloadData()
    }
    
    private func setupTableView() {
        feedViewScreen.tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: "Authpost")
        feedViewScreen.tableView.rowHeight = UITableView.automaticDimension
           
        // Set an estimated row height (optional, helps with performance)
        feedViewScreen.tableView.estimatedRowHeight = 150
    }
    
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        AuthModel().getCurrentUserDetails { userDetails, error in
            guard error == nil else {
                print("Error fetching user details: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            guard let follows = userDetails["follows"] as? [DocumentReference], !follows.isEmpty else {
                completion([])
                return
            }

            let db = Firestore.firestore()
            var posts = [Post]()
            let group = DispatchGroup()
            
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
                posts.sort { $0.timestamp > $1.timestamp }
                completion(posts)
            }
        }
    }
 

}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedViewScreen.searchBar.text?.isEmpty ?? true ? posts.count : filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Authpost", for: indexPath) as! FeedTableViewCell
        let post = feedViewScreen.searchBar.text?.isEmpty ?? true ? posts[indexPath.row] : filteredPosts[indexPath.row]

        cell.configure(with: post, author: nil, at: indexPath)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak tableView] in
            post.authorRef.getDocument { [weak tableView] documentSnapshot, error in
                guard let tableView = tableView else { return }

                if let error = error {
                    print("Error fetching author details for \(post.author): \(error.localizedDescription)")
                } else if let data = documentSnapshot?.data() {
                    DispatchQueue.main.async {
                        if let visibleCell = tableView.cellForRow(at: indexPath) as? FeedTableViewCell {
                            visibleCell.configure(with: post, author: data, at: indexPath)
                        }
                    }
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = feedViewScreen.searchBar.text?.isEmpty ?? true ? posts[indexPath.row] : filteredPosts[indexPath.row]
        displayReview(review: selectedPost)
    }
    
    private func displayReview(review: Post) {
        let showReviewController = ShowReviewViewController(review: review)
        self.navigationController?.pushViewController(showReviewController, animated: true)
    }
}
