//
//  ViewProfileTableViewController.swift
//  PassportChallenge
//
//  Created by Josh Huerkamp on 6/2/18.
//  Copyright © 2018 Josh Huerkamp. All rights reserved.
//

import Foundation
import UIKit

class ViewProfileTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noImageLabel: UILabel!
    var keyRef = ""
    var profile = Profile()
    var hobbies: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let image = profile.image {
            imageButton.imageView?.image = image
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        hobbies = profile.hobbies
        return 1 + hobbies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ViewProfileDetailsCell", for: indexPath) as! ViewProfileDetailsTableCell
            cell.nameLabel.text = profile.name
            cell.ageLabel.text = profile.age
            cell.genderLabel.text = profile.gender
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyCell", for: indexPath) as! ViewProfileHobbyCell
            cell.hobbyLabel.text = hobbies[indexPath.row - 1]
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 160
        }
        return 50
    }
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
    }
}
