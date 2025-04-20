//
//  MockSessionStore.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 15/04/2025.
//

import Foundation
import Firebase
import FirebaseFirestore
@testable import MediStock

@MainActor
class MockSessionStore: ObservableObject {
    
    // MARK: - Error Enum
    enum MockSessionStoreError: Error {
        case userNotFound
        case signInFailed
        case signUpFailed
        case signOutFailed
        case fetchUserDataFailed
        case updateUserNameFailed

        var localizedDescription: String {
            switch self {
            case .userNotFound:
                return "User not found. Please check your email or sign up."
            case .signInFailed:
                return "Unable to sign in. Please check your email and password."
            case .signUpFailed:
                return "Unable to sign up. Please try again."
            case .signOutFailed:
                return "Unable to sign out. Please try again."
            case .fetchUserDataFailed:
                return "Unable to load user data. Please try again."
            case .updateUserNameFailed:
                return "Failed to update user name."
            }
        }
    }

    // MARK: - Constants
    private let userDataService: UserDataService

    // MARK: - Properties
    @Published var session: MediStock.User?
    @Published var email: String = ""
    @Published var fullName: String = ""
    @Published var profileImageURL: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    @Published var appearancePreference: AppearancePreference {
        didSet {
            print("Préférence changée en : \(appearancePreference)")
            UserDefaults.standard.set(appearancePreference.rawValue, forKey: "appearancePreference")
        }
    }

    var handle: AuthStateDidChangeListenerHandle?

    var shouldThrowSignInError = false
    var shouldThrowSignUpError = false
    var shouldThrowSignOutError = false
    var shouldThrowFetchUserDataError = false
    var shouldThrowUpdateUserNameError = false
    
    private var mockUsers: [String: MediStock.User] = [:]

    // MARK: - Init
    init(userDataService: UserDataService = MockUserDataService()) {
        self.userDataService = userDataService
        if let savedPreference = UserDefaults.standard.string(forKey: "appearancePreference"),
           let preference = AppearancePreference(rawValue: savedPreference) {
            appearancePreference = preference
        } else {
            appearancePreference = .system
        }
        let defaultUser = MediStock.User(id: "testUserID1", email: "test@example.com", fullName: "Jean Dupont", profileImageURL: "https://example.com/profile.jpg")
        mockUsers["test@example.com"] = defaultUser
    }

    // MARK: - Functions
    func listen() {
        if let user = mockUsers["test@example.com"] {
            session = user
            email = user.email
            fullName = user.fullName
            profileImageURL = user.profileImageURL
        } else {
            session = nil
            email = ""
            fullName = ""
            profileImageURL = ""
            errorMessage = nil
        }
    }

    func signUp(email: String, password: String) async {
        errorMessage = nil
        if shouldThrowSignUpError {
            errorMessage = MockSessionStoreError.signUpFailed.localizedDescription
            return
        }

        let newUser = MediStock.User(id: UUID().uuidString, email: email, fullName: "New User", profileImageURL: "")
        mockUsers[email] = newUser
        session = newUser
        await fetchUserData(userId: newUser.id)
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        if shouldThrowSignInError {
            errorMessage = MockSessionStoreError.signInFailed.localizedDescription
            return
        }

        if let user = mockUsers[email] {
            session = user
            await fetchUserData(userId: user.id)
        } else {
            errorMessage = MockSessionStoreError.userNotFound.localizedDescription
        }
    }

    func signOut() {
        if shouldThrowSignOutError {
            errorMessage = MockSessionStoreError.signOutFailed.localizedDescription
            return
        }

        session = nil
        email = ""
        fullName = ""
        profileImageURL = ""
        errorMessage = nil
    }

    func unbind() {
        handle = nil
    }

    func fetchUserData(userId: String) async {
        print("Starting fetchUserData for userId: \(userId) at \(Date())")
        if shouldThrowFetchUserDataError {
            errorMessage = MockSessionStoreError.fetchUserDataFailed.localizedDescription
            return
        }

        if let user = mockUsers.values.first(where: { $0.id == userId }) {
            session = user
            email = user.email
            fullName = user.fullName
            profileImageURL = user.profileImageURL
        } else {
            errorMessage = MockSessionStoreError.userNotFound.localizedDescription
        }
        print("Finished fetchUserData at \(Date())")
    }

    func updateUserName(newName: String) async throws {
        isLoading = true
        errorMessage = nil

        guard let userId = session?.id else {
            errorMessage = "User not found"
            isLoading = false
            throw MockSessionStoreError.userNotFound
        }

        if shouldThrowUpdateUserNameError {
            errorMessage = MockSessionStoreError.updateUserNameFailed.localizedDescription
            isLoading = false
            throw MockSessionStoreError.updateUserNameFailed
        }

        do {
            try await userDataService.updateUserName(userId: userId, newName: newName)
            await fetchUserData(userId: userId)
        } catch {
            errorMessage = MockSessionStoreError.updateUserNameFailed.localizedDescription
            isLoading = false
            throw error
        }

        isLoading = false
    }
}
