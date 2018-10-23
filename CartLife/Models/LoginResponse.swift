//
//  LoginResponse.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/21/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//


import Foundation

struct LoginResponse: Codable {
    let data: DataClass?
    let errorCode: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case errorCode = "error_code"
        case message
    }
}

struct DataClass: Codable {
    let token: String
    let userID: Int
    let name, email, contactNumber, profilePic: String?
    
    enum CodingKeys: String, CodingKey {
        case token
        case userID = "user_id"
        case name, email
        case contactNumber = "contact_number"
        case profilePic = "profile_pic"
    }
}
