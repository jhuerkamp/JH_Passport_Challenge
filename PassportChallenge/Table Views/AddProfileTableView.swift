//
//  AddProfileTableView.swift
//  PassportChallenge
//
//  Created by Josh Huerkamp on 6/2/18.
//  Copyright © 2018 Josh Huerkamp. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AddProfileTableView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIButton!
    
    var hobbies: [String] = [""]
    
    //Firebase vars
    var profileRef: DatabaseReference!
    var profiles: [DataSnapshot]! = []
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddProfileTableView.saveProfile))
        navigationItem.rightBarButtonItem = saveButton
        
        //Populate Firebase reference
        profileRef = Database.database().reference(withPath: "profiles")
        storageRef = Storage.storage().reference()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + hobbies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailsCell", for: indexPath) as! AddProfileDetailsCell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "HobbyCell", for: indexPath) as! AddProfileHobbyCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 165
        } else {
            return 65
        }
    }
    
    @IBAction func addHobbyTapped(_ sender: UIButton) {
        hobbies.append("")
        tableView.reloadData()
    }
    
    @objc
    func saveProfile() {
        if let image = profileImage.backgroundImage(for: .normal) {
            if let data = UIImageJPEGRepresentation(image, 0.9) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
                let imageName = "profilePics/\(formatter.string(from:Date())).jpg"
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let imageStoreTask = storageRef.child(imageName).putData(data, metadata: metadata)
                
                let uploadAlert = UIAlertController(title: "Uploading Image", message: nil, preferredStyle: .alert)
                uploadAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (cancel) in
                    guard let strongSelf = self else { return }
                    imageStoreTask.cancel()
                    uploadAlert.dismiss(animated: true, completion: nil)
                    strongSelf.saveProfileData(imageName: nil)

                }))
                
                present(uploadAlert, animated: true, completion: nil)
                
                imageStoreTask.observe(.success) { [weak self] (snapshot) in
                    guard let strongSelf = self else { return }
                    strongSelf.saveProfileData(imageName: imageName)
                    uploadAlert.dismiss(animated: true, completion: nil)
                }
                
                imageStoreTask.observe(.failure) { (snapshot) in
                    NSLog("there was a problem \(snapshot)")
                }
            }
        } else {
            saveProfileData(imageName: nil)
        }

    }
    
    func saveProfileData(imageName: String?) {
        var profileData: [String: Any] = [:]
        
        if let detailCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddProfileDetailsCell {
            if let nameText = detailCell.nameText.text,
                let genderText = detailCell.genderText.text,
                let ageText = detailCell.ageText.text {
                profileData[ProfileFields.name] = nameText
                profileData[ProfileFields.gender] = genderText
                profileData[ProfileFields.age] = ageText
            }
        }
        
        for i in 0 ..< hobbies.count {
            if let hobbyCell = tableView.cellForRow(at: IndexPath(row: i+1, section: 0)) as? AddProfileHobbyCell {
                hobbies[i] = hobbyCell.hobbyText.text!
            }
        }
        profileData[ProfileFields.hobbies] = hobbies
        if let tempName = imageName {
            profileData[ProfileFields.imageUrl] = tempName
        }
        
        profileRef.childByAutoId().setValue(profileData)
        hobbies = [""]
    }
    
    @IBAction func addImageTapped(_ sender: UIButton) {
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
    
    @objc
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileImage.setBackgroundImage(image, for: UIControlState.normal)
        profileImage.title(for: .normal)
        dismiss(animated:true, completion: nil)
    }
}
