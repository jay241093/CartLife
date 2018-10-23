//
//  RoutesResponse.swift
//  CartLife
//
//  Created by Ravi Dubey on 10/22/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import Foundation

struct RoutesResponse: Codable {
    let data: [Datum1]
    let errorCode: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case errorCode = "error_code"
        case message
    }
}

struct Datum1: Codable {
    let id, userID: Int
    let from, to, createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case from, to
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
