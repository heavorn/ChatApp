//
//  LoginControllerHandle.swift
//  ChatApp
//
//  Created by Sovorn on 9/13/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//


import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleRegister(){
        
        guard let email = emailText.text, let password = passwordText.text, let name = nameText.text else {
            print("Form is not valid.")
            return
            
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (User, error) in
            if error != nil {
                print(error!)
                return
            }
            
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            let storageFile = Storage.storage().reference().child("\(imageName).jpg")
            
            if let uploadData = UIImageJPEGRepresentation(self.profileImage.image!, 0.1) {
//            if let uploadData = UIImagePNGRepresentation(self.profileImage.image!) {
                storageFile.putData(uploadData, metadata: nil) { (StorageMetadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    storageFile.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        if let profileImageUrl = url?.absoluteString {
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                            self.registerUserIntoDatabase(userID: userID, values: values as [String : AnyObject])
                        }
                    })
                }
            }
        }
        
    }
    
    private func registerUserIntoDatabase(userID: String, values: [String: AnyObject]){
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let userReferece = ref.child("users").child(userID)
        
        
        
        userReferece.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleSelectedProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editImage = info["UIImagePickerControllerEidtedImage"] as? UIImage {
            selectedImageFromPicker = editImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
