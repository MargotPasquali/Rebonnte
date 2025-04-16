//
//  MockUserDataService.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 15/04/2025.
//

import Foundation
import FirebaseFirestore
@testable import MediStock

final class MockUserDataService: UserDataService {

    // MARK: - Enum
    enum MockUserDataServiceError: Error {
        case updateUserNameFailed
        
        var localizedDescription: String {
            switch self {
            case .updateUserNameFailed:
                return "Failed to update user name."
            }
        }
    }

    // MARK: - Properties
    var userNames: [String: String] = [:]

    var shouldThrowUpdateUserNameError = false
    
    // MARK: - Init with default data
    init(userNames: [String: String] = ["testUserID1": "John Doe"]) {
        self.userNames = userNames
    }
    
    // MARK: - Functions
    func updateUserName(userId: String, newName: String) async throws {
        if shouldThrowUpdateUserNameError {
            throw MockUserDataServiceError.updateUserNameFailed
        }
        userNames[userId] = newName
    }
}
