//
//  HOCTabs.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class HOCTabs: UITabBarController, UITabBarControllerDelegate {

    var imageProfile: UIImageView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            self.delegate = self
        
            self.navigationItem.title = ""
        
            navigationItem.hidesBackButton = true
        
            NotificationCenter.default.addObserver(self, selector: #selector(logoutCompleted), name: NSNotification.Name("logoutCompleted"), object: nil)
            
            // Create LoggedInHomeViewController
            let feedVC = FeedViewController()
            let feedNavVC = UINavigationController(rootViewController: feedVC)
            feedNavVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "newspaper"), tag: 0)
        
            let exploreVC = ExploreViewController()
            let exploreNavVC = UINavigationController(rootViewController: exploreVC)
            exploreNavVC.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        
        var role = "User"
        var profileImg = ""
        AuthModel().getCurrentUserDetails { (userDetails, error) in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
            } else {
                let followedCritics: [String]
                if let tags = userDetails["tags"] as? [String] {
                    followedCritics = tags
                } else {
                    followedCritics = []
                }
                
                if let error = error {
                    print("Error fetching user details: \(error.localizedDescription)")
                } else {
                    if let img = userDetails["profileImageURL"] as? String {
                        profileImg = img
                    } else {
                        profileImg = ""
                    }
                    
                    if let roleName = userDetails["role"] as? String {
                        role = roleName
                    } else {
                        role = "User"
                    }
                    print(userDetails)
                    
                    // Assign user details to variables
                    var userProfile = Profile(
                        name: userDetails["name"] as? String,
                        email: userDetails["email"] as? String,
                        followedCritics: followedCritics,
                        phoneType: "",
                        profileImage: profileImg,
                        phone: 1234567890,
                        role: role,
                        tags: followedCritics,
                        rating: userDetails["rating"] as? Double ?? 0.0,
                        address1: "",
                        address2: "",
                        address3: ""
                    )
                    
                    let profileVC = ShowProfileViewController(profileInfo: userProfile)
                    let profileNavVC = UINavigationController(rootViewController: profileVC)
                    profileNavVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 0)
                    
                    if(role == "Critic"){
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create Post", style: .plain, target: self, action: #selector(self.AddTapped))
                        
                    }
                    
                    self.viewControllers = [feedNavVC, exploreNavVC, profileNavVC]
                }
            }
            
            self.customizeTabBarItems()
        }
            
        }
    
    private func customizeTabBarItems() {
            // Change the color of tab bar item images
            if let items = tabBar.items {
                for item in items {
                    if let image = item.image {
                        item.image = image.withRenderingMode(.alwaysOriginal)
                        item.selectedImage = image.withRenderingMode(.alwaysOriginal)
                        item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .selected)
                    }
                }
            }
        }

    
    @objc func AddTapped(){
        let newPostVC = NewPostViewController()
        navigationController?.pushViewController(newPostVC, animated: true)
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            // Prevent the title from switching to "Welcome" when a tab is selected
            if let selectedViewController = selectedViewController {
                selectedViewController.navigationItem.title = item.title
            }
    }
    
    @objc func logoutCompleted() {
        // Dismiss the UITabBarController
        self.dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }

}

extension HOCTabs {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 0 {
            // If the selected view controller is the first one (FeedViewController)
            if let feedNavVC = viewController as? UINavigationController,
               let feedVC = feedNavVC.viewControllers.first as? FeedViewController {
                // Reload table data in the FeedViewController
                feedVC.reloadTableData()
            }
        }
        
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 1 {
            // If the selected view controller is the first one (FeedViewController)
            if let exploreNavVC = viewController as? UINavigationController,
               let exploreNavVC = exploreNavVC.viewControllers.first as? ExploreViewController {
                // Reload table data in the ExploreViewController
                exploreNavVC.reloadTableData()
            }
        }
    }
}
