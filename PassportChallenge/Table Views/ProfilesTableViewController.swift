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
import FirebaseAuth

class ProfilesTableViewController: UITableViewController, SortProfileDelegate {
    //Firebase observers
    fileprivate var addedObserver: DatabaseHandle?
    fileprivate var changedObserver: DatabaseHandle?
    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var profiles: [Profile] = []
    var sortBy: SortFilter = .none
    var orderBy: OrderBy = .none
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "profiles")
        storageRef = Storage.storage().reference()
        
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously(completion: { (authResult, error) in
                if let _ = error {
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        profiles = []
        
        if let observer = addedObserver  {
            ref.removeObserver(withHandle: observer)
        }
        
        if let observer = changedObserver {
            ref.removeObserver(withHandle: observer)
        }
    }
    
    func setObservers() {
        // Listen for new messages in the Firebase database
        if sortBy == .none {
            addedObserver = ref.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
                guard let strongSelf = self else { return }
                
                strongSelf.displayProfiles(snapshot: snapshot)
            })
        } else if sortBy == .male || sortBy == .female {
            addedObserver = ref.queryOrdered(byChild: ProfileFields.gender).queryEqual(toValue: sortBy.rawValue).observe(.value) { [weak self] (snapshots) in
                guard let strongSelf = self else { return }
                if let snapshot = snapshots.children.allObjects as? [DataSnapshot] {
                    for temp in snapshot {
                        strongSelf.displayProfiles(snapshot: temp)
                    }
                    if strongSelf.orderBy == .desc {
                        strongSelf.profiles.reverse()
                    }
                }
                strongSelf.tableView.reloadData()
            }
        } else {
            addedObserver = ref.queryOrdered(byChild: sortBy.rawValue).observe(.value) { [weak self] (snapshots) in
                guard let strongSelf = self else { return }

                if let snapshot = snapshots.children.allObjects as? [DataSnapshot] {
                    for temp in snapshot {
                        strongSelf.displayProfiles(snapshot: temp)
                    }
                    if strongSelf.orderBy == .desc {
                        strongSelf.profiles.reverse()
                    }
                }
                strongSelf.tableView.reloadData()
            }
        }
        
        changedObserver = ref.observe(.childChanged, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            
            for var c in strongSelf.profiles {
                if c.key == snapshot.key {
//                    let index = strongSelf.profiles.index(of: c)
//                    strongSelf.profiles[index!] = snapshot
                    
                    if let tempProfile = snapshot.value as? [String: Any] {
                        c = strongSelf.convertToProfile(tempProfile: tempProfile, key: c.key)
                    }
                }
            }
            strongSelf.tableView.reloadData()
        })
    }
    
    func downloadImage(profile: Profile) {
        if let _ = profile.image { return }
        
        storageRef.child(profile.imageName).getData(maxSize: 10 * 1024 * 1024) { [weak self](data, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                NSLog("Download error: \(error)")
            } else if let imagedata = data {
                profile.image = UIImage(data: imagedata)
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    func convertToProfile(tempProfile: [String: Any], key: String) -> Profile {
        let profile = Profile()
        profile.key = key
        profile.name = tempProfile[ProfileFields.name] as! String
        profile.gender = tempProfile[ProfileFields.gender] as! String
        profile.age = tempProfile[ProfileFields.age] as! String
        profile.hobbies = tempProfile[ProfileFields.hobbies] as! [String]
        
        if let tempName = tempProfile[ProfileFields.imageName] as? String {
            profile.imageName = tempName
        }
        
        return profile
    }
    
    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func sortTapped(_ sender: UIBarButtonItem) {
        guard let sortView = storyboard?.instantiateViewController(withIdentifier: "SortProfileTableViewController") as? SortProfileTableViewController
            else { return }
        
        sortView.sortBy = sortBy
        sortView.orderBy = orderBy
        sortView.delegate = self
        navigationController?.present(sortView, animated: true, completion: nil)
    }
    
    func sortBy(newSort: SortFilter, newOrder: OrderBy) {
        sortBy = newSort
        orderBy = newOrder
        profiles = []
    }
    
    func displayProfiles(snapshot: DataSnapshot) {
        if let tempProfile = snapshot.value as? [String: Any] {
            profiles.append(convertToProfile(tempProfile: tempProfile, key: snapshot.key))
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfilesTableCell
        let profile = profiles[indexPath.row]

        
        cell.nameLabel.text = profile.name
        cell.ageLabel.text = profile.age
        cell.genderLabel.text = profile.gender
        
        
        if let profileImage = profile.image {
            cell.profileImage.image = profileImage
        } else if profile.imageName.count > 0 {
            downloadImage(profile: profile)
        }
        
        if profile.gender.lowercased() == "m" || profile.gender.lowercased() == "male" {
            cell.backgroundColor = UIColor(red: 0/255.0, green: 102.0/255.0, blue: 204.0/255, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor(red: 255.0/255.0, green: 153.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
        
        cell.hobbiesLabel.text = "Hobbies: "
        for hobby in profile.hobbies {
            cell.hobbiesLabel.text! += "\(hobby)"
            if profile.hobbies.index(of: hobby)! < profile.hobbies.count - 1 {
                cell.hobbiesLabel.text! += ", "
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let profileView = storyboard?.instantiateViewController(withIdentifier: "ViewProfileTableViewController") as? ViewProfileTableViewController
            else { return }
        profileView.profile = profiles[indexPath.row]
    
        navigationController?.pushViewController(profileView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
