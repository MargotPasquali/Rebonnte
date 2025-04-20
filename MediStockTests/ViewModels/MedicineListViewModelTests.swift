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
        mockService.shouldThrowObserveMedicinesError = false
        viewModel.searchText = ""
        viewModel.isLoading = false
        viewModel.errorMessage = nil
        viewModel.sortOption = .name
        viewModel.medicines = []
    }

    @Test
    func testObserveMedicinesSuccess() async throws {
        // Given
        resetState()
        
        // When
        viewModel.startObserving()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.medicines.count == 4, "Expected 4 medicines to be observed")
        if viewModel.medicines.count == 4 {
            #expect(viewModel.medicines[0].name == "Amoxicillin")
            #expect(viewModel.medicines[1].name == "Aspirin")
            #expect(viewModel.medicines[2].name == "Ibuprofen")
            #expect(viewModel.medicines[3].name == "Paracetamol")
        }
    }

//    @Test
//    func testObserveMedicinesFailure() async throws {
//        // Given
//        resetState()
//        mockService.shouldThrowObserveMedicinesError = true
//        
//        // When
//        viewModel.startObserving()
//        
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        // Then
//        #expect(viewModel.isLoading == false)
//        #expect(viewModel.errorMessage == nil)
//        #expect(viewModel.medicines.isEmpty)
//    }

    @Test
    func testObserveMedicinesSortedByStockSuccess() async throws {
        // Given
        resetState()
        viewModel.sortOption = .stock
        
        // When
        viewModel.startObserving()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.medicines.count == 4, "Expected 4 medicines to be observed")
        if viewModel.medicines.count == 4 {
            #expect(viewModel.medicines[0].stock == 20)
            #expect(viewModel.medicines[1].stock == 30)
            #expect(viewModel.medicines[2].stock == 50)
            #expect(viewModel.medicines[3].stock == 75)
        }
    }

    @Test
    func testFilteredMedicinesSearchSuccess() async throws {
        // Given
        resetState()
        viewModel.startObserving()
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
