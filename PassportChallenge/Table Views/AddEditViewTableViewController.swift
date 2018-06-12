//
//  AddEditViewTableViewController.swift
//  PassportChallenge
//
//  Created by Josh Huerkamp on 6/2/18.
//  Copyright © 2018 Josh Huerkamp. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

enum AddEditMode: Int {
    case add = 1
    case edit
}

class AddEditViewTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveDeleteButton: UIButton!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    
    
    var keyRef = ""
    var profile = Profile()
    var hobbies: [String] = []
    var profileUpdate: [String: Any] = [:]
    var viewMode: AddEditMode = .add
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keyboard scrolling
        NotificationCenter.default.addObserver(self,
                selector: #selector(AddEditViewTableViewController.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                selector: #selector(AddEditViewTableViewController.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        // Change VC look depending on add or view/edit profile
        switch viewMode {
        case .add:
            profile.hobbies = [""]
            saveDeleteButton.setTitle("Save", for: .normal)
            saveDeleteButton.addTarget(self, action: #selector(AddEditViewTableViewController.updateProfile), for: .touchUpInside)
            imageButton.setTitle("Add Image", for: .normal)
            navigationItem.title = "Add Profile"
            let barButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddEditViewTableViewController.cancelAdd))
            navigationItem.rightBarButtonItem = barButton
        default:
            blurEffectView.isHidden = true
            view.backgroundColor = UIColor.white
            saveDeleteButton.setTitle("Delete", for: .normal)
            saveDeleteButton.addTarget(self, action: #selector(AddEditViewTableViewController.deleteTapped), for: .touchUpInside)
            let barButton = UIBarButtonItem(title: "Update", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddEditViewTableViewController.updateProfile))
            navigationItem.rightBarButtonItem = barButton
            navigationItem.title = "View/Edit Profile"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageButton.setBackgroundImage(profile.image.image, for: .normal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - tableview delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + profile.hobbies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailsCell", for: indexPath) as! AddProfileDetailsCell
            if viewMode == .edit {
                cell.nameText.text = profile.name
                cell.ageText.text = profile.age
                cell.genderText.text = profile.gender
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyCell", for: indexPath) as! AddProfileHobbyCell
            if viewMode == .edit {
                cell.hobbyText.text = profile.hobbies[indexPath.row - 1]
            }
            
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
    
    // MARK: - Textfield/Keyboard functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        })
    }
    
    // MARK: - Image functions
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        profile.image = UIImageView(image: image)
        imageButton.setBackgroundImage(image, for: UIControlState.normal)
        imageButton.setTitle("", for: .normal)
        dismiss(animated:true, completion: nil)
    }
    
    @IBAction func addHobbyTapped(_ sender: UIButton) {
        profile.hobbies.append("")
        tableView.reloadData()
    }
        
    @objc
    func deleteTapped() {
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
    func cancelAdd() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Save/Update functions
    @objc
    func updateProfile() {
        if let image = imageButton.backgroundImage(for: .normal) {
            if let data = UIImageJPEGRepresentation(image, 0.9) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
                let imageName = "profilePic\(formatter.string(from:Date())).jpg"
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let imageStoreTask = Storage.storage().reference().child(imageName).putData(data, metadata: metadata)
                
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
            if detailCell.nameText.text!.count > 0
                && detailCell.genderText.text!.count > 0
                && detailCell.ageText.text!.count > 0 {
                profileUpdate[ProfileFields.name] = detailCell.nameText.text
                profileUpdate[ProfileFields.age] = detailCell.ageText.text
                
                if detailCell.genderText.text!.lowercased() == "m" || detailCell.genderText.text!.lowercased() == "male" {
                    profileUpdate[ProfileFields.gender] = "Male"
                } else {
                    profileUpdate[ProfileFields.gender] = "Female"
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
                
                if viewMode == .edit {
                    Database.database().reference(withPath: "profiles").child(profile.key).setValue(profileUpdate)
                    navigationController?.popViewController(animated: true)
                } else {
                    Database.database().reference(withPath: "profiles").childByAutoId().setValue(profileUpdate)
                    dismiss(animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Profile Incomplete", message: "Please fill out all profile fields", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
}
