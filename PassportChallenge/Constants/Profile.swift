//
//  Profile.swift
//  PassportChallenge
//
//  Created by Josh Huerkamp on 6/3/18.
//  Copyright © 2018 Josh Huerkamp. All rights reserved.
//

import Foundation
import UIKit

class Profile {
    
    struct fields {
        static let hobbies = "hobbies"
        static let name = "name"
        static let gender = "gender"
        static let age = "age"
        static let image = "image"
    }
    
    var hobbies: [String] = [""]
    var name = ""
    var gender = ""
    var age = ""
    var image = UIImage()
}


