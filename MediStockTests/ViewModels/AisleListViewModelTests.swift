//
//  AisleListViewModelTests.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 16/04/2025.
//

import Testing
import Foundation
import FirebaseFirestoreSwift
@testable import MediStock

@MainActor
@Suite("AisleListViewModel")
class AisleListViewModelTests {
    
    let viewModel: AisleListViewModel
    let mockService: MockMedicineDataService
    
    init() {
        mockService = MockMedicineDataService()
        viewModel = AisleListViewModel(medicineDataService: mockService)
    }
    
    func resetState() {
        mockService.aisles = ["A1", "B2"]
        mockService.shouldThrowFetchAislesError = false
        viewModel.aisles = []
        viewModel.isLoading = false
        viewModel.errorMessage = nil
    }
    
    @Test
    func testFetchAislesSuccess() async throws {
        // Given
        resetState()
        
        // When
        await viewModel.fetchAisles()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.aisles == ["A1", "B2"])
    }
    
    @Test
    func testFetchAislesFailure() async throws {
        // Given
        resetState()
        mockService.shouldThrowFetchAislesError = true
        
        // When
        await viewModel.fetchAisles()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "Failed to fetch aisle list.")
        #expect(viewModel.aisles.isEmpty)
    }
}
