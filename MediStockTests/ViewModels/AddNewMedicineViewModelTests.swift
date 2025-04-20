//
//  AddNewMedicineViewModelTests.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 15/04/2025.
//

import Testing
import Foundation
import FirebaseFirestoreSwift
@testable import MediStock

@MainActor
@Suite("AddNewMedicineViewModel")
class AddNewMedicineViewModelTests {
    
    var viewModel: AddNewMedicineViewModel!
    var mockService: MockMedicineDataService!

    func setup() {
        mockService = MockMedicineDataService()
        viewModel = AddNewMedicineViewModel(medicineDataService: mockService)
    }

    @Test
    func testAddMedicineSuccess() async throws {
        // Given
        setup()
        viewModel.name = "Ibuprofen"
        viewModel.stock = 25
        viewModel.aisle = "C3"
        let initialMedicinesCount = mockService.medicines.count
        mockService.shouldThrowCheckForDuplicateError = false
        mockService.shouldThrowAddMedicineError = false
        
        // When
        await viewModel.addNewMedecine()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.name == "")
        #expect(viewModel.stock == 0)
        #expect(viewModel.aisle == "")
        #expect(mockService.medicines.count == initialMedicinesCount + 1)
        #expect(mockService.medicines.contains { $0.name == "Ibuprofen" && $0.stock == 25 && $0.aisle == "C3" })
    }

    @Test
    func testAddMedicineInvalidDataEmptyName() async throws {
        // Given
        setup()
        viewModel.name = ""
        viewModel.stock = 25
        viewModel.aisle = "C3"
        let initialMedicinesCount = mockService.medicines.count
        
        // When
        await viewModel.addNewMedecine()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == "Invalid data provided.")
        #expect(viewModel.isLoading == false)
        #expect(mockService.medicines.count == initialMedicinesCount)
    }

    @Test
    func testAddMedicineInvalidDataEmptyAisle() async throws {
        // Given
        setup()
        viewModel.name = "Ibuprofen"
        viewModel.stock = 25
        viewModel.aisle = ""
        let initialMedicinesCount = mockService.medicines.count
        
        // When
        await viewModel.addNewMedecine()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == "Invalid data provided.")
        #expect(viewModel.isLoading == false)
        #expect(mockService.medicines.count == initialMedicinesCount)
    }

    @Test
    func testAddMedicineInvalidDataStockOutOfRange() async throws {
        // Given
        setup()
        viewModel.name = "Ibuprofen"
        viewModel.stock = 101
        viewModel.aisle = "C3"
        let initialMedicinesCount = mockService.medicines.count
        
        // When
        await viewModel.addNewMedecine()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == "Invalid data provided.")
        #expect(viewModel.isLoading == false)
        #expect(mockService.medicines.count == initialMedicinesCount)
    }

    @Test
    func testAddMedicineDuplicate() async throws {
        // Given
        setup()
        viewModel.name = "Aspirin"
        viewModel.stock = 25
        viewModel.aisle = "C3"
        mockService.shouldThrowCheckForDuplicateError = false
        mockService.shouldThrowAddMedicineError = false
        mockService.medicines.append(Medicine(id: "existingID", name: "Aspirin", stock: 50, aisle: "A1"))
        let initialMedicinesCount = mockService.medicines.count
        
        // When
        await viewModel.addNewMedecine()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == "Medicine already exists.")
        #expect(viewModel.isLoading == false)
        #expect(mockService.medicines.count == initialMedicinesCount)
    }

    @Test
    func testAddMedicineFailureDuringAdd() async throws {
        // Given
        setup()
        viewModel.name = "Ibuprofen"
        viewModel.stock = 25
        viewModel.aisle = "C3"
        mockService.shouldThrowCheckForDuplicateError = false
        mockService.shouldThrowAddMedicineError = true
        let initialMedicinesCount = mockService.medicines.count
        
        // When
        await viewModel.addNewMedecine()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == "Failed to add new medicine.")
        #expect(viewModel.isLoading == false)
        #expect(mockService.medicines.count == initialMedicinesCount)
    }

    @Test
    func testAddMedicineFailureDuringCheckDuplicate() async throws {
        // Given
        setup()
        viewModel.name = "Ibuprofen"
        viewModel.stock = 25
        viewModel.aisle = "C3"
        mockService.shouldThrowCheckForDuplicateError = true
        mockService.shouldThrowAddMedicineError = false
        let initialMedicinesCount = mockService.medicines.count
        
        // When
        await viewModel.addNewMedecine()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == "Failed to add new medicine.")
        #expect(viewModel.isLoading == false)
        #expect(mockService.medicines.count == initialMedicinesCount)
    }
}
