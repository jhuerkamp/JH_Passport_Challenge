//
//  ProfilesTableViewController.swift
//  PassportChallenge
//
//  Created by Josh Huerkamp on 6/2/18.
//  Copyright © 2018 Josh Huerkamp. All rights reserved.
//

import Foundation
import UIKit

class ProfilesTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfilesTableCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
