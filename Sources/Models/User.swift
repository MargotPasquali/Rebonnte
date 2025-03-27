//
//  User.swift
//  MediStock
//
//  Created by Margot Pasquali on 25/03/2025.
//

import Foundation

struct User: Codable {
    var id: String
    let email: String
    let fullName: String
    let profileImageURL: String
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case profileImageURL = "profile_image_url"
    }
}
