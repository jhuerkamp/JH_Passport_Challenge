//
//  ProfilesTableViewController.swift
//  PassportChallenge
//
//  Created by Josh Huerkamp on 6/2/18.
//  Copyright © 2018 Josh Huerkamp. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class ProfilesTableViewController: UITableViewController {
    //Firebase observers
    fileprivate var addedObserver: DatabaseHandle?
    fileprivate var changedObserver: DatabaseHandle?
    var ref: DatabaseReference!
    var profiles: [DataSnapshot]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "profiles")
        
        setObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let observer = addedObserver  {
            ref.removeObserver(withHandle: observer)
        }
        
        if let observer = changedObserver {
            ref.removeObserver(withHandle: observer)
        }
    }
    
    func setObservers() {
        // Listen for new messages in the Firebase database
        addedObserver = self.ref.queryOrderedByKey().observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.profiles.append(snapshot)
            strongSelf.tableView.reloadData()
        })
        
        changedObserver = ref.queryOrderedByKey().observe(.childChanged, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            
            for c in strongSelf.profiles {
                if c.key == snapshot.key {
                    let index = strongSelf.profiles.index(of: c)
                    strongSelf.profiles[index!] = snapshot
                }
            }
            strongSelf.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfilesTableCell
        guard let profile = profiles[indexPath.row].value as? [String:Any] else { return cell }
        
        
        cell.nameLabel.text = profile[Profile.fields.name] as? String
        cell.ageLabel.text = profile[Profile.fields.age] as? String
        
        if let gender = profile[Profile.fields.gender] as? String {
            cell.genderLabel.text = gender
            
            if gender.lowercased() == "m" || gender.lowercased() == "male" {
                cell.backgroundColor = UIColor.blue
            } else {
                cell.backgroundColor = UIColor(red: 255.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
            }
        }
        cell.genderLabel.text = profile[Profile.fields.gender] as? String
        
        if let hobbies = profile[Profile.fields.hobbies] as? String {
            cell.hobbiesLabel.text = "Hobbies: \(hobbies)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
