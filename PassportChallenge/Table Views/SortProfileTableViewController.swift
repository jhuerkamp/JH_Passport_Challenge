//
//  SortProfileTableViewController.swift
//  PassportChallenge
//
//  Created by Josh Huerkamp on 6/8/18.
//  Copyright © 2018 Josh Huerkamp. All rights reserved.
//

import Foundation
import UIKit

protocol SortProfileDelegate {
    func sortBy(newSort: SortFilter, newOrder: OrderBy)
}

enum SortFilter: String {
    case male = "Male"
    case female = "Female"
    case age = "age"
    case name = "name"
    case none = "None"
}

enum OrderBy: String {
    case asc = "asc"
    case desc = "desc"
    case none = "none"
}

class SortProfileTableViewController: UITableViewController {
    
    var delegate: SortProfileDelegate?
    var sortBy: SortFilter = .none
    var orderBy: OrderBy = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(SortProfileTableViewController.cancelSort))
        navigationItem.rightBarButtonItem = cancelButton
        navigationItem.title = "Sort Profiles"
    }
    
    // MARK: - Tableview functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Filter"
        } else {
            return "Sort"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
                switch indexPath.row {
                case 1:
                    cell.textLabel?.text = "Male"
                    updateSelectedCell(selectedFilter: .male, cell: cell)
                case 2:
                    cell.textLabel?.text = "Female"
                    updateSelectedCell(selectedFilter: .female, cell: cell)
                default:
                    cell.textLabel?.text = "None"
                    updateSelectedCell(selectedFilter: .none, cell: cell)
                }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath)
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Name"
                updateSelectedCell(selectedFilter: .name, cell: cell)
            default:
                cell.textLabel?.text = "Age"
                updateSelectedCell(selectedFilter: .age, cell: cell)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedFilter: SortFilter = .none
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                selectedFilter = .male
            case 2:
                selectedFilter = .female
            default:
                selectedFilter = .none
            }
            selectFilter(selectedFilter: selectedFilter)
        case 1:
            switch indexPath.row {
            case 0:
                updateSort(selectedSort: .name)
            case 1:
                updateSort(selectedSort: .age)
            default:
                sortBy = .none
            }
        default:
            sortBy = .none
        }
        
        delegate?.sortBy(newSort: sortBy, newOrder: orderBy)
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func cancelSort() {
        dismiss(animated: true, completion: nil)
    }
    
    func updateSort(selectedSort: SortFilter) {
        if sortBy == selectedSort {
            if orderBy == .desc {
                orderBy = .none
                sortBy = .none
                return
            }
            orderBy = .desc
            return
        }
        orderBy = .asc
        sortBy = selectedSort
    }
    
    func updateSelectedCell(selectedFilter: SortFilter, cell: UITableViewCell) {
        if sortBy == selectedFilter {
            cell.accessoryType = .checkmark
            
            switch orderBy {
            case .asc:
                cell.detailTextLabel?.text = "Asc"
            case .desc:
                cell.detailTextLabel?.text = "Desc"
            default:
                cell.detailTextLabel?.text = ""
            }
        } else {
            cell.accessoryType = .none
            cell.detailTextLabel?.text = ""

        }
    }
    
    func selectFilter(selectedFilter: SortFilter) {
        if sortBy != selectedFilter {
            sortBy = selectedFilter
        } else {
            sortBy = .none
        }
        orderBy = .none
    }
}
