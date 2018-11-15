//
//  RegisterResponse.swift
//  CartLife
//
//  Created by Ravi Dubey on 9/21/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import Foundation


struct RegisterResponse: Codable {
    let data: DataClass1?
    let errorCode: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case errorCode = "error_code"
        case message
    }
}

struct DataClass1: Codable {
    let name, email, password: String?
    let roleID, regType: Int?
    let deviceID, updatedAt, createdAt: String?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case name, email, password
        case roleID = "role_id"
        case regType = "reg_type"
        case deviceID = "device_id"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case id
    }
}
