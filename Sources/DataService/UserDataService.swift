//
//  UserDataService.swift
//  MediStock
//
//  Created by Margot Pasquali on 13/04/2025.
//

import Foundation
import FirebaseFirestore

// MARK: - Protocol
protocol UserDataService {
    func updateUserName(userId: String, newName: String) async throws
}

final class RemoteUserDataService: UserDataService {

    // MARK: - Constants
    private let data = Firestore.firestore()
    private let collection = "users"

    // MARK: - Functions
    func updateUserName(userId: String, newName: String) async throws {
        try await data.collection(collection).document(userId).updateData([
            "full_name": newName
        ])
    }
}
