//
//  MedicineDetailViewModelTests.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 16/04/2025.
//

import Testing
import Foundation
import FirebaseFirestoreSwift
@testable import MediStock

@MainActor
@Suite("MedicineDetailViewModel")
class MedicineDetailViewModelTests {
    
    let viewModel: MedicineDetailViewModel
    let mockService: MockMedicineDataService
    
    init() {
        mockService = MockMedicineDataService()
        viewModel = MedicineDetailViewModel(medicineDataService: mockService)
    }
    
    func resetState() {
        mockService.medicines = [
            Medicine(id: "medicineID1", name: "Aspirin", stock: 50, aisle: "A1"),
            Medicine(id: "medicineID2", name: "Paracetamol", stock: 30, aisle: "B2")
        ]
        mockService.history = [
            HistoryEntry(id: "history1", medicineId: "medicineID1", fullName: "Jean Dupont", action: "Added", details: "Added medicine", timestamp: Date())
        ]
        mockService.shouldThrowFetchMedicinesError = false
        mockService.shouldThrowRemoveMedicinesError = false
        mockService.shouldThrowModifyMedicineError = false
        mockService.shouldThrowFetchHistoryError = false
        viewModel.medicines = []
        viewModel.history = []
        viewModel.isLoading = false
        viewModel.errorMessage = nil
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
        #expect(viewModel.medicines.count == 2)
        #expect(viewModel.medicines[0].name == "Aspirin")
        #expect(viewModel.medicines[1].name == "Paracetamol")
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
        #expect(viewModel.errorMessage == "Failed to fetch medicines.")
        #expect(viewModel.medicines.isEmpty)
    }
    
    @Test
    func testDeleteMedicinesSuccess() async throws {
        // Given
        resetState()
        await viewModel.fetchMedicines()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let initialMedicinesCount = mockService.medicines.count
        
        // When
        await viewModel.deleteMedicines(at: IndexSet(integer: 0))
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.medicines.count == initialMedicinesCount - 1)
        #expect(viewModel.medicines.count == initialMedicinesCount - 1)
        #expect(viewModel.medicines[0].name == "Paracetamol")
    }
    
    @Test
    func testDeleteMedicinesFailure() async throws {
        // Given
        resetState()
        await viewModel.fetchMedicines()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let initialMedicinesCount = mockService.medicines.count
        mockService.shouldThrowRemoveMedicinesError = true
        
        // When
        await viewModel.deleteMedicines(at: IndexSet(integer: 0))
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == "Failed to delete medicines.")
        #expect(mockService.medicines.count == initialMedicinesCount)
    }
    
    @Test
    func testModifyMedicineSuccess() async throws {
        // Given
        resetState()
        let medicine = Medicine(id: "medicineID1", name: "Aspirin", stock: 75, aisle: "A1")
        let user = "Jean Dupont"
        let changes = [MedecineChangeRequest.stockChanged]
        
        // When
        await viewModel.modifyMedicine(medicine, user: user, changes: changes)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.medicines.first(where: { $0.id == "medicineID1" })?.stock == 75)
        #expect(mockService.history.contains { $0.medicineId == "medicineID1" && $0.action == "Modified" && $0.details == "Medicine stock changed" })
    }
    
    @Test
    func testModifyMedicineFailure() async throws {
        // Given
        resetState()
        let medicine = Medicine(id: "medicineID1", name: "Aspirin", stock: 75, aisle: "A1")
        let user = "Jean Dupont"
        let changes = [MedecineChangeRequest.stockChanged]
        mockService.shouldThrowModifyMedicineError = true
        
        // When
        await viewModel.modifyMedicine(medicine, user: user, changes: changes)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == "Failed to modify medicine.")
    }
    
    @Test
    func testFetchHistorySuccess() async throws {
        // Given
        resetState()
        let medicine = Medicine(id: "medicineID1", name: "Aspirin", stock: 50, aisle: "A1")
        
        // When
        await viewModel.fetchHistory(for: medicine)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.history.count == 1)
        #expect(viewModel.history[0].medicineId == "medicineID1")
        #expect(viewModel.history[0].action == "Added")
    }
    
    @Test
    func testFetchHistoryFailure() async throws {
        // Given
        resetState()
        let medicine = Medicine(id: "medicineID1", name: "Aspirin", stock: 50, aisle: "A1")
        mockService.shouldThrowFetchHistoryError = true
        
        // When
        await viewModel.fetchHistory(for: medicine)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Then
        #expect(viewModel.errorMessage == "Failed to fetch history.")
        #expect(viewModel.history.isEmpty)
    }
}
