//
//  AddProfileTableView.swift
//  PassportChallenge
//
//  Created by Josh Huerkamp on 6/2/18.
//  Copyright © 2018 Josh Huerkamp. All rights reserved.
//

import Foundation
import UIKit

class AddProfileTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var profile = Profile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        let doneButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddProfileTableView.saveProfile))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + profile.hobbies.count
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
        profile.hobbies.append("")
        tableView.reloadData()
    }
    
    @objc
    func saveProfile() {
        if let detailCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddProfileDetailsCell {
            if let nameText = detailCell.nameText.text,
                let genderText = detailCell.genderText.text,
                let ageText = detailCell.ageText.text {
                    profile.name = nameText
                    profile.gender = genderText
                    profile.age = ageText
                
                //Clear text fields
                detailCell.nameText.text = ""
                detailCell.genderText.text = ""
                detailCell.ageText.text = ""
            }
        }

        for i in 0 ..< profile.hobbies.count {
            if let hobbyCell = tableView.cellForRow(at: IndexPath(row: i+1, section: 0)) as? AddProfileHobbyCell {
                profile.hobbies[i] = hobbyCell.hobbyText.text!
            }
        }
    }
}
