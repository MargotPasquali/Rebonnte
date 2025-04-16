//
//  UserTests.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 15/04/2025.
//

import Testing
import Foundation
@testable import MediStock

@Suite("User")
struct UserTests {

    @Test
    func createUserWithAllProperties() {
        let id = "testUID"
        let email = "test@example.com"
        let fullName = "Test User"
        let profileImageURL = "Test URL"
        
        let user = User(id: id, email: email, fullName: fullName, profileImageURL: profileImageURL)
        
        #expect(user.id == id)
        #expect(user.email == email)
        #expect(user.fullName == fullName)
        #expect(user.profileImageURL == profileImageURL)
    }
    
    @Test
    func createUserWithNilFullName() {
        let id = "testUID"
        let email = "test@example.com"
        let fullName: String? = nil
        let profileImageURL = "Test URL"
        
        let user = User(id: id, email: email, fullName: fullName ?? "", profileImageURL: profileImageURL)
        
        #expect(user.id == id)
        #expect(user.email == email)
        #expect(user.fullName == "")
        #expect(user.profileImageURL == profileImageURL)
    }

    @Test
    func createUserWithNilProfileImage() {
        let id = "testUID"
        let email = "test@example.com"
        let fullName = "Test User"
        let profileImageURL: String? = nil
        
        let user = User(id: id, email: email, fullName: fullName, profileImageURL: profileImageURL ?? "")
        
        #expect(user.id == id)
        #expect(user.email == email)
        #expect(user.fullName == fullName)
        #expect(user.profileImageURL == "")
    }
}
