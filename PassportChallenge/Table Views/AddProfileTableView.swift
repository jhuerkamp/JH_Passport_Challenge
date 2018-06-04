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
import FirebaseDatabase

class AddProfileTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var hobbies: [String] = [""]
    
    //Firebase vars
    var profileRef: DatabaseReference!
    var profiles: [DataSnapshot]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddProfileTableView.saveProfile))
        navigationItem.rightBarButtonItem = saveButton
        
        //Populate Firebase reference
        profileRef = Database.database().reference(withPath: "profiles")
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
        var profileData: [String: Any] = [:]
        
        if let detailCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddProfileDetailsCell {
            if let nameText = detailCell.nameText.text,
                let genderText = detailCell.genderText.text,
                let ageText = detailCell.ageText.text {
                    profileData[Profile.fields.name] = nameText
                    profileData[Profile.fields.gender] = genderText
                    profileData[Profile.fields.age] = ageText
                
                    //Clear text fields
                    detailCell.nameText.text = ""
                    detailCell.genderText.text = ""
                    detailCell.ageText.text = ""
            }
        }

        for i in 0 ..< hobbies.count {
            if let hobbyCell = tableView.cellForRow(at: IndexPath(row: i+1, section: 0)) as? AddProfileHobbyCell {
                hobbies[i] = hobbyCell.hobbyText.text!
                hobbyCell.hobbyText.text = ""
            }
        }
        profileData[Profile.fields.hobbies] = hobbies
        
        profileRef.childByAutoId().setValue(profileData)
        hobbies = [""]
        tableView.reloadData()
    }
}
