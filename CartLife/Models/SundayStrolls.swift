//
//  SundayStrolls.swift
//  CartLife
//
//  Created by Ravi Dubey on 10/22/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import Foundation

struct Sundaystrolls: Codable {
    let data: [Datum]
    let errorCode: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case errorCode = "error_code"
        case message
    }
}

struct Datum: Codable {
    let id: Int
    let placeName, placeAddress, image, description: String
    let rating: String
    let review: String?
    let status: Int
    let createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case placeName = "place_name"
        case placeAddress = "place_address"
        case image, description, rating, review, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
