//
//  ViewController.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 11/19/24.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    
    let homeScreen = HomeView()
    
    private var posts: [Post] = []


    
    override func loadView() {
           view = homeScreen
            fetchPosts { [weak self] fetchedPosts in
            guard let self = self else { return }
            self.posts = fetchedPosts
            DispatchQueue.main.async {
            self.homeScreen.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        
        homeScreen.tableView.delegate = self
        homeScreen.tableView.dataSource = self
        
        homeScreen.registerBtn.addTarget(self, action: #selector(registerBtnTapped), for: .touchUpInside)
        homeScreen.loginBtn.addTarget(self, action: #selector(loginBtnTapped), for: .touchUpInside)
        
    }
    
    @objc func registerBtnTapped(){
            let registerController = RegisterViewController()
            navigationController?.pushViewController(registerController, animated: true)
    }
    
    @objc func loginBtnTapped(){
            let loginController = LoginViewController()
            navigationController?.pushViewController(loginController, animated: true)
    }
    
    private func setupTableView() {
            homeScreen.tableView.register(ExploreTableViewCell.self, forCellReuseIdentifier: "Authpost")
    }
    
    private func fetchPosts(completion: @escaping ([Post]) -> Void) {
            let db = Firestore.firestore()
        var posts = [Post]()
            
            db.collection("posts").getDocuments { (querySnapshot, error) in
                guard let querySnapshot = querySnapshot, error == nil else {
                    print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                for document in querySnapshot.documents {
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let content = data["content"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let imageUrl = data["image"] as? String ?? ""
                    let tags = data["tags"] as? [String] ?? []
                    let author = data["author"] as? String ?? ""
                    let rating = data["rating"] as? Double ?? 0.0
                    
                    let post = Post(
                        title: title,
                        content: content,
                        timestamp: timestamp,
                        image: imageUrl,
                        tags: tags,
                        author: author,
                        rating: rating
                    )
                    posts.append(post)
                }
                
                // Sort posts by timestamp in descending order
                posts.sort { $0.timestamp > $1.timestamp }
        
                completion(posts)
            }
        }
}


extension ViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Authpost", for: indexPath) as! ExploreTableViewCell
        let post = posts[indexPath.row]
        cell.configure(with: post, at: indexPath)
        print(post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.posts[indexPath.row]);
        
        let review = posts[indexPath.row]
        let showReviewController = ShowReviewViewController(review: review)
        self.navigationController?.pushViewController(showReviewController, animated: true)
    }
}

