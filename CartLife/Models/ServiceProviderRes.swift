//
//  ServiceProviderRes.swift
//  CartLife
//
//  Created by Ravi Dubey on 10/22/18.
//  Copyright © 2018 Ravi Dubey. All rights reserved.
//

import Foundation


struct ServiceProviderRes: Codable {
    let data: [Datum2]
    let errorCode: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case errorCode = "error_code"
        case message
    }
}

struct Datum2: Codable {
    let id: Int
    let name, address, contactNumber, email: String
    let image, rating: String
    let review: String?
    let status: Int
    let createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, address
        case contactNumber = "contact_number"
        case email, image, rating, review, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


// MARK: Encode/decode helpers
