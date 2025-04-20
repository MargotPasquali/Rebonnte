//
//  User.swift
//  MediStock
//
//  Created by Margot Pasquali on 25/03/2025.
//

import Foundation

struct User: Identifiable, Codable {
    // MARK: - Constants
    let id: String
    let email: String
    let fullName: String
    let profileImageURL: String

    // MARK: - Coding keys
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case profileImageURL = "profile_image_url"
    }
}
