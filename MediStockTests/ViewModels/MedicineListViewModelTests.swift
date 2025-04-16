//
//  MedicineListViewModelTests.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 16/04/2025.
//

import Testing
import Foundation
import FirebaseFirestoreSwift
@testable import MediStock

@MainActor
@Suite("MedicineListViewModel")
class MedicineListViewModelTests {
    
    let viewModel: MedicineListViewModel
    let mockService: MockMedicineDataService
    
    init() {
        mockService = MockMedicineDataService()
        viewModel = MedicineListViewModel(medicineDataService: mockService)
    }
    
    func resetState() {
        mockService.medicines = [
            Medicine(id: "medicineID1", name: "Aspirin", stock: 50, aisle: "A1"),
            Medicine(id: "medicineID2", name: "Paracetamol", stock: 30, aisle: "B2"),
            Medicine(id: "medicineID3", name: "Ibuprofen", stock: 75, aisle: "C3"),
            Medicine(id: "medicineID4", name: "Amoxicillin", stock: 20, aisle: "D4")
        ]
        mockService.shouldThrowFetchMedicinesError = false
        mockService.shouldThrowFetchMedicinesSortedByNameError = false
        mockService.shouldThrowFetchMedicinesSortedByStockError = false
        viewModel.searchText = ""
        viewModel.isLoading = false
        viewModel.errorMessage = nil
        viewModel.sortOption = .none
        viewModel.canLoadMore = true
        viewModel.medicines = []
        viewModel.displayedMedicines = []
    }
    
    @Test
    func testFetchMedicinesSuccess() async throws {
        // Given
        resetState()
        
        // When
        await viewModel.fetchMedicines()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.medicines.count == 4, "Expected 4 medicines to be fetched")
        #expect(viewModel.displayedMedicines.count == 4)
        #expect(viewModel.canLoadMore == false)
        if viewModel.medicines.count >= 2 {
            #expect(viewModel.medicines[0].name == "Aspirin")
            #expect(viewModel.medicines[1].name == "Paracetamol")
        }
    }
    
    @Test
    func testFetchMedicinesFailure() async throws {
        // Given
        resetState()
        mockService.shouldThrowFetchMedicinesError = true
        
        // When
        await viewModel.fetchMedicines()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "Failed to fetch medicines")
        #expect(viewModel.medicines.isEmpty)
        #expect(viewModel.displayedMedicines.isEmpty)
        #expect(viewModel.canLoadMore == true)
    }
    
    @Test
    func testFetchMedicinesSortedByNameSuccess() async throws {
        // Given
        resetState()
        
        // When
        await viewModel.fetchMedicinesSortedByName()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.medicines.count == 4, "Expected 4 medicines to be fetched")
        #expect(viewModel.displayedMedicines.count == 4)
        #expect(viewModel.canLoadMore == false)
        if viewModel.medicines.count == 4 {
            #expect(viewModel.medicines[0].name == "Amoxicillin")
            #expect(viewModel.medicines[1].name == "Aspirin")
            #expect(viewModel.medicines[2].name == "Ibuprofen")
            #expect(viewModel.medicines[3].name == "Paracetamol")
        }
    }
    
    @Test
    func testFetchMedicinesSortedByNameFailure() async throws {
        // Given
        resetState()
        mockService.shouldThrowFetchMedicinesSortedByNameError = true
        
        // When
        await viewModel.fetchMedicinesSortedByName()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "Failed to fetch medicine by name")
        #expect(viewModel.medicines.isEmpty)
        #expect(viewModel.displayedMedicines.isEmpty)
        #expect(viewModel.canLoadMore == true)
    }
    
    @Test
    func testFetchMedicinesSortedByStockSuccess() async throws {
        // Given
        resetState()
        
        // When
        await viewModel.fetchMedicinesSortedByStock()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.medicines.count == 4, "Expected 4 medicines to be fetched")
        #expect(viewModel.displayedMedicines.count == 4)
        #expect(viewModel.canLoadMore == false)
        if viewModel.medicines.count == 4 {
            #expect(viewModel.medicines[0].stock == 20)
            #expect(viewModel.medicines[1].stock == 30)
            #expect(viewModel.medicines[2].stock == 50)
            #expect(viewModel.medicines[3].stock == 75)
        }
    }
    
    @Test
    func testFetchMedicinesSortedByStockFailure() async throws {
        // Given
        resetState()
        mockService.shouldThrowFetchMedicinesSortedByStockError = true
        
        // When
        await viewModel.fetchMedicinesSortedByStock()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "Failed to fetch medicine by stock")
        #expect(viewModel.medicines.isEmpty)
        #expect(viewModel.displayedMedicines.isEmpty)
        #expect(viewModel.canLoadMore == true)
    }
    
    @Test
    func testLoadMoreMedicinesSuccess() async throws {
        // Given
        resetState()
        // Add more medicines
        mockService.medicines = (1...15).map { Medicine(id: "medicineID\($0)", name: "Medicine \($0)", stock: $0, aisle: "A\($0)") }
        await viewModel.fetchMedicines()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.displayedMedicines.count == 12)
        #expect(viewModel.canLoadMore == true)
        
        // LoadMore
        viewModel.loadMoreMedicines()
        
        // Then
        #expect(viewModel.displayedMedicines.count == 15)
        #expect(viewModel.canLoadMore == false)
    }
    
    @Test
    func testFilteredMedicinesSearchSuccess() async throws {
        // Given
        resetState()
        await viewModel.fetchMedicines()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // When
        viewModel.searchText = "aspirin"
        
        // Then
        #expect(viewModel.filteredMedicines.count == 1)
        if !viewModel.filteredMedicines.isEmpty {
            #expect(viewModel.filteredMedicines[0].name == "Aspirin")
        }
        
        // When
        viewModel.searchText = "xyz"
        
        // Then
        #expect(viewModel.filteredMedicines.isEmpty)
    }
}
