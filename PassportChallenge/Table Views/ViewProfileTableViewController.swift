//
//  ViewProfileTableViewController.swift
//  PassportChallenge
//
//  Created by Josh Huerkamp on 6/2/18.
//  Copyright © 2018 Josh Huerkamp. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class ViewProfileTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noImageLabel: UILabel!
    var keyRef = ""
    var profile = Profile()
    var hobbies: [String] = []
    var ref: StorageReference!
    var profileUpdate: [String: Any] = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let updateButton = UIBarButtonItem(title: "Update", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewProfileTableViewController.updateProfile))
        navigationItem.rightBarButtonItem = updateButton
        
        if let image = profile.image {
            imageButton.imageView?.image = image
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + profile.hobbies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailsCell", for: indexPath) as! AddProfileDetailsCell
            cell.nameText.text = profile.name
            cell.ageText.text = profile.age
            cell.genderText.text = profile.gender
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyCell", for: indexPath) as! AddProfileHobbyCell
            cell.hobbyText.text = profile.hobbies[indexPath.row - 1]
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            profile.hobbies.remove(at: indexPath.row - 1)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 160
        }
        return 50
    }
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alert = UIAlertController(title: "Image from...", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { [weak self] (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    guard let strongSelf = self else { return }
                    imagePicker.sourceType = .camera;
                    strongSelf.present(imagePicker, animated: true, completion: nil)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Image Picker", style: UIAlertActionStyle.default, handler: { [weak self] (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    guard let strongSelf = self else { return }
                    imagePicker.sourceType = .photoLibrary;
                    strongSelf.present(imagePicker, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        if profile.imageName.count > 0 {
            Storage.storage().reference().child(profile.imageName).delete { (error) in
                if let error = error {
                    NSLog("There was a problem deleting the profile: \(error)")
                }
            }
        }
        Database.database().reference(withPath: "profile").child(profile.key).removeValue()
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageButton.setBackgroundImage(image, for: UIControlState.normal)
        imageButton.title(for: .normal)
        dismiss(animated:true, completion: nil)
    }
    
    @objc
    func updateProfile() {
        if let image = imageButton.backgroundImage(for: .normal) {
            if let data = UIImageJPEGRepresentation(image, 0.9) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
                let imageName = "profilePics/\(formatter.string(from:Date())).jpg"
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let imageStoreTask = ref.child(imageName).putData(data, metadata: metadata)
                
                let uploadAlert = UIAlertController(title: "Uploading Image", message: nil, preferredStyle: .alert)
                uploadAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (cancel) in
                    guard let strongSelf = self else { return }
                    imageStoreTask.cancel()
                    uploadAlert.dismiss(animated: true, completion: nil)
                    strongSelf.saveProfileUpdate(imageName: nil)
                    
                }))
                
                present(uploadAlert, animated: true, completion: nil)
                
                imageStoreTask.observe(.success) { [weak self] (snapshot) in
                    guard let strongSelf = self else { return }
                    strongSelf.saveProfileUpdate(imageName: imageName)
                    uploadAlert.dismiss(animated: true, completion: nil)
                }
                
                imageStoreTask.observe(.failure) { (snapshot) in
                    NSLog("there was a problem \(snapshot)")
                }
            }
        } else {
            saveProfileUpdate(imageName: nil)
        }
    }
    
    func saveProfileUpdate(imageName: String?) {
        if let detailCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddProfileDetailsCell {
            if let nameText = detailCell.nameText.text,
                let genderText = detailCell.genderText.text,
                let ageText = detailCell.ageText.text {
                profileUpdate[ProfileFields.name] = nameText
                profileUpdate[ProfileFields.age] = ageText
                
                if genderText.lowercased() == "m" || genderText.lowercased() == "male" {
                    profileUpdate[ProfileFields.gender] = "Male"
                } else {
                    profileUpdate[ProfileFields.gender] = "Female"
                }
            }
        }
        
        for i in 0 ..< profile.hobbies.count {
            if let hobbyCell = tableView.cellForRow(at: IndexPath(row: i+1, section: 0)) as? AddProfileHobbyCell {
                profile.hobbies[i] = hobbyCell.hobbyText.text!
            }
        }
        profileUpdate[ProfileFields.hobbies] = profile.hobbies
        if let tempName = imageName {
            profileUpdate[ProfileFields.imageName] = tempName
        }
        
        Database.database().reference(withPath: "profiles").child(profile.key).setValue(profileUpdate)
    }
}
