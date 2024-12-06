//
//  ShowProfileViewController.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/6/24.
//

import UIKit
import FirebaseAuth

class ShowProfileViewController: UIViewController {

    var delegate: ViewController!
    let showProfileScreen = ShowProfileView()
    let profileInfo: Profile
    
    override func loadView() {
        view = showProfileScreen
    }
    
    init(profileInfo: Profile) {
       self.profileInfo = profileInfo
       super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let unwrappedName = profileInfo.name,
           let unwrappedEmail = profileInfo.email,
           let unwrappedPhoneNum = profileInfo.phone,
           let uwRole = profileInfo.role,
           let unwrappedProfileImage = profileInfo.profileImage,
           let unwrappedPhoneType = profileInfo.phoneType,
           let unwrappedAddress1 = profileInfo.address1,
           let unwrappedAddress2 = profileInfo.address2,
           let unwrappedAddress3 = profileInfo.address3 {
            if !unwrappedName.isEmpty{
                showProfileScreen.labelName.text = "\(unwrappedName)"
            }
            if !unwrappedEmail.isEmpty{
                showProfileScreen.labelEmail.text = "Email: " + unwrappedEmail
            }

            if !uwRole.isEmpty{
                showProfileScreen.labelRole.text = "Role: " + "\(uwRole)"
            }
            if (!profileInfo.tags.isEmpty) {
                showProfileScreen.labelTags.text = "Expertise: " + "\(profileInfo.tags.joined(separator: ", "))"
            }
            
            if (!unwrappedProfileImage.isEmpty) {
                if let imageUrl = URL(string: unwrappedProfileImage ?? "") {
                    loadImage(from: imageUrl)
                } else {
                    showProfileScreen.imageProfile.image = UIImage(named: "defaultImage")
                }
            }

        }
        
        showProfileScreen.buttonLogout.addTarget(self, action: #selector(logoutBtnTapped), for: .touchUpInside)
    }
    
    @objc func logoutBtnTapped(){
        do {
            try Auth.auth().signOut()
            print("Logout successful")
            NotificationCenter.default.post(name: NSNotification.Name("logoutCompleted"), object: nil)

        } catch {
            print("Logout failed with error: \(error.localizedDescription)")
            showAlert(message: "Logout failed with error: \(error.localizedDescription)")
        }
    }
    
    func onEditProfile(profile: Profile){
        if let unwrappedName = profile.name,
           let unwrappedEmail = profile.email,
           let unwrappedPhoneNum = profile.phone,
           let unwrappedProfileImage = profile.profileImage,
           let unwrappedPhoneType = profile.phoneType,
           let unwrappedAddress1 = profile.address1,
           let unwrappedAddress2 = profile.address2,
           let unwrappedAddress3 = profile.address3 {
            if !unwrappedName.isEmpty{
                showProfileScreen.labelName.text = "\(unwrappedName)"
            }
            if !unwrappedEmail.isEmpty{
                showProfileScreen.labelEmail.text = "Email: " + unwrappedEmail
            }
            
            showProfileScreen.labelRole.text = "Phone: " + "\(unwrappedPhoneNum)" + " (\(unwrappedPhoneType))"
            
            showProfileScreen.labelAddressHeading.text = "Address:"
            if !unwrappedAddress1.isEmpty{
                showProfileScreen.labelAddress1.text = unwrappedAddress1
            }
            if !unwrappedAddress2.isEmpty{
                showProfileScreen.labelAddress2.text = unwrappedAddress2
            }
            if !unwrappedAddress3.isEmpty{
                showProfileScreen.labelZip.text = unwrappedAddress3
            }
        }
        
        // TODO: Save the changed profile fields
        
    }
    
    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                // Set default image if loading fails
                DispatchQueue.main.async {
                    self?.showProfileScreen.imageProfile.image = UIImage(named: "defaultImage")
                }
                return
            }
            DispatchQueue.main.async {
                // Set image from data
                self?.showProfileScreen.imageProfile.image = UIImage(data: data)
            }
        }
        task.resume()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}