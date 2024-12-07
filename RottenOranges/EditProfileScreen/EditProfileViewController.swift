//
//  EditProfileViewController.swift
//  RottenOranges
//
//  Created by Darshan Bhokare on 12/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import Foundation
 
class EditProfileViewController: UIViewController, ObservableObject, UITextFieldDelegate {
 
    let registerScreen = EditProfileView()
    let model = AuthModel()
    
    let userInfo: Profile
    
    init(userInfo: Profile) {
       self.userInfo = userInfo
       super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pickedImage:UIImage?
    
    override func loadView() {
       view = registerScreen
    }
 
    override func viewDidLoad() {
 
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
            tapRecognizer.cancelsTouchesInView = false
            view.addGestureRecognizer(tapRecognizer)
        
        title = "Edit Profile"
        
        // Prepopulate fields with existing data from userInfo
        registerScreen.nameField.text = userInfo.name
        registerScreen.emailField.text = userInfo.email
        
        if let imageURLString = userInfo.profileImage, let storageURL = URL(string: imageURLString) {
            loadImage(from: storageURL)
        }

        registerScreen.registerBtn.addTarget(self, action: #selector(registerBtnTapped), for: .touchUpInside)
                
        registerScreen.buttonTakePhoto.menu = getMenuImagePicker()
        

        
    }

    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                // Set default image if loading fails
                DispatchQueue.main.async {
                    self?.registerScreen.buttonTakePhoto.setImage(
                        UIImage(named: "defaultImage")?.withRenderingMode(.alwaysOriginal),
                        for: .normal
                    )
                }
                return
            }
            DispatchQueue.main.async {
                // Set image from data
                if let image = UIImage(data: data) {
                    self?.registerScreen.buttonTakePhoto.setImage(
                        image.withRenderingMode(.alwaysOriginal),
                        for: .normal
                    )
                    self?.pickedImage = image // Save for future updates
                }
            }
        }
        task.resume()
    }

    
    func getMenuImagePicker() -> UIMenu{
           var menuItems = [
               UIAction(title: "Camera",handler: {(_) in
                   self.pickUsingCamera()
               }),
               UIAction(title: "Gallery",handler: {(_) in
                   self.pickPhotoFromGallery()
               })
           ]
           
           return UIMenu(title: "Select source", children: menuItems)
    }
    
    func pickUsingCamera(){
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.allowsEditing = true
        cameraController.delegate = self
        present(cameraController, animated: true)
    }
        
    
    func pickPhotoFromGallery(){
        var configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.any(of: [.images])
        configuration.selectionLimit = 1
                
        let photoPicker = PHPickerViewController(configuration: configuration)
                
        photoPicker.delegate = self
        present(photoPicker, animated: true, completion: nil)
    }
    
    
    @objc func hideKeyboardOnTap(){
        //MARK: removing the keyboard from screen...
        view.endEditing(true)
    }
    
    @objc func registerBtnTapped() {
        let name = registerScreen.nameField.text ?? ""
        let email = registerScreen.emailField.text?.lowercased() ?? ""
        
        if !isValidEmail(email) {
            self.showAlert(message: "Invalid Email")
            return
        }
        
        if name.isEmpty || email.isEmpty {
            showAlert(message: "Please enter all name, email, and other details.")
            return
        }

        let updatedData: [String: Any] = [
            "name": name,
            "email": email
        ]
        
        // Add profile image data if available
        if let image = self.pickedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
            let storageRef = Storage.storage().reference().child("userImages/\(UUID().uuidString).jpg")
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    self.showAlert(message: "Failed to upload image: \(error.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        self.showAlert(message: "Failed to retrieve image URL: \(error.localizedDescription)")
                        return
                    }
                    
                    if let downloadURL = url {
                        var updatedDataWithImage = updatedData
                        updatedDataWithImage["profileImageURL"] = downloadURL.absoluteString
                        
                        self.updateUserData(name: name, updatedData: updatedDataWithImage)
                    }
                }
            }
        } else {
            // Update without profile image
            self.updateUserData(name: name, updatedData: updatedData)
        }
        
        self.navigationController?.popViewController(animated: true)
    }

    private func updateUserData(name: String, updatedData: [String: Any]) {
        model.getUserByUsername(username: name) { userData, documentId, error in
            if let error = error {
                self.showAlert(message: "Failed to retrieve user: \(error.localizedDescription)")
                return
            }
            
            guard let documentId = documentId else {
                self.showAlert(message: "User document not found.")
                return
            }
            
            self.model.editUser(documentId: documentId, updatedData: updatedData) { error in
                if let error = error {
                    self.showAlert(message: "Failed to update user: \(error.localizedDescription)")
                } else {
                    self.showAlert(message: "User updated successfully!")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }


    
    func isValidEmail(_ email: String) -> Bool {
            
            let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"#
            return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    private func navigateToLoginViewController() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
 
}


extension EditProfileViewController:PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        print(results)
        
        let itemprovider = results.map(\.itemProvider)
        
        for item in itemprovider{
            if item.canLoadObject(ofClass: UIImage.self){
                item.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in
                    DispatchQueue.main.async{
                        if let uwImage = image as? UIImage{
                            self.registerScreen.buttonTakePhoto.setImage(
                                uwImage.withRenderingMode(.alwaysOriginal),
                                for: .normal
                            )
                            self.pickedImage = uwImage
                        }
                    }
                })
            }
        }
    }
}


extension EditProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage{
            self.registerScreen.buttonTakePhoto.setImage(
                image.withRenderingMode(.alwaysOriginal),
                for: .normal
            )
            self.pickedImage = image
        }else{
          
        }
    }
}


