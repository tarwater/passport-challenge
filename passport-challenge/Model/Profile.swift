//
//  Profile.swift
//  passport-challenge
//
//  Created by Holt, Robert on 6/25/18.
//  Copyright © 2018 Holt, Robert. All rights reserved.
//

import Foundation

class Profile {
    
    let name: String
    let age: Int
    let gender: String
    var hobbies: String
    var image: String
    let id: String
    
    init(name: String, gender: String, age: Int, hobbies: String, image: String, id: String){
        self.name = name
        self.gender = gender
        self.age = age
        self.hobbies = hobbies
        self.image = image
        self.id = id
    }
    
}
