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
        mockService.medicines = [
            Medicine(id: "1", name: "Aspirin", stock: 50, aisle: "A1"),
            Medicine(id: "2", name: "Paracetamol", stock: 30, aisle: "B2")
        ]
        mockService.shouldThrowObserveMedicinesWithoutSortError = false
        viewModel.aisles = []
        viewModel.isLoading = false
        viewModel.errorMessage = nil
    }

    @Test
    func testObserveAislesSuccess() async throws {
        // Given
        resetState()
        
        // When
        viewModel.startObserving()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.aisles == ["A1", "B2"])
    }

}
