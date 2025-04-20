//
//  MockMedicineDataService.swift
//  MediStockTests
//
//  Created by Margot Pasquali on 15/04/2025.
//

import Foundation
import FirebaseFirestore
@testable import MediStock

final class MockMedicineDataService: MedicineDataService {
    
    // MARK: - Enum
    enum MockMedicineDataServiceError: Error {
        case observeMedicinesFailed
        case observeMedicinesWithoutSortFailed
        case observeHistoryFailed
        case checkForDuplicateFailed
        case removeMedicinesFailed
        case modifyMedicineFailed
        case addMedicineFailed
        
        var localizedDescription: String {
            switch self {
            case .observeMedicinesFailed:
                return "Failed to observe medicines."
            case .observeMedicinesWithoutSortFailed:
                return "Failed to observe medicines without sort."
            case .observeHistoryFailed:
                return "Failed to observe history."
            case .checkForDuplicateFailed:
                return "Failed to check for duplicate medicine."
            case .removeMedicinesFailed:
                return "Failed to remove medicines."
            case .modifyMedicineFailed:
                return "Failed to modify medicine."
            case .addMedicineFailed:
                return "Failed to add medicine."
            }
        }
    }

    // MARK: - Properties
    var medicines: [Medicine] = []
    var history: [HistoryEntry] = []
    var isListening: Bool = false
    private var medicinesCompletion: (([Medicine]) -> Void)?
    private var historyCompletions: [String: ([HistoryEntry]) -> Void] = [:]

    var shouldThrowObserveMedicinesError = false
    var shouldThrowObserveMedicinesWithoutSortError = false
    var shouldThrowObserveHistoryError = false
    var shouldThrowCheckForDuplicateError = false
    var shouldThrowRemoveMedicinesError = false
    var shouldThrowModifyMedicineError = false
    var shouldThrowAddMedicineError = false

    // MARK: - Init with default data
    init(medicines: [Medicine] = [
        Medicine(id: "testMedicineID1", name: "Aspirin", stock: 50, aisle: "A1"),
        Medicine(id: "testMedicineID2", name: "Paracetamol", stock: 30, aisle: "B2")
    ], history: [HistoryEntry] = [
        HistoryEntry(id: "history1", medicineId: "testMedicineID1", fullName: "Test User", action: "Added", details: "Added medicine", timestamp: Date())
    ]) {
        self.medicines = medicines
        self.history = history
    }

    // MARK: - Functions
    func observeMedicines(sortOption: SortOption, completion: @escaping ([Medicine]) -> Void) {
        isListening = true
        medicinesCompletion = completion
        if shouldThrowObserveMedicinesError {
            completion([]) // Return empty list to simulate failure
            return
        }
        let sortedMedicines: [Medicine]
        switch sortOption {
        case .name:
            sortedMedicines = medicines.sorted { $0.name < $1.name }
        case .stock:
            sortedMedicines = medicines.sorted { $0.stock < $1.stock }
        }
        completion(sortedMedicines)
    }

    func observeMedicinesWithoutSort(completion: @escaping ([Medicine]) -> Void) {
        isListening = true
        medicinesCompletion = completion
        if shouldThrowObserveMedicinesWithoutSortError {
            completion([])
            return
        }
        completion(medicines)
    }

    // Observe history for a specific medicine and call completion with results
    func observeMedicineHistory(for medicine: Medicine, completion: @escaping ([HistoryEntry]) -> Void) {
        guard let medicineId = medicine.id else {
            completion([])
            return
        }
        isListening = true
        historyCompletions[medicineId] = completion
        if shouldThrowObserveHistoryError {
            completion([])
            return
        }
        let filteredHistory = history.filter { $0.medicineId == medicineId }
        completion(filteredHistory)
    }

    func checkForDuplicate(name: String) async throws -> Bool {
        if shouldThrowCheckForDuplicateError {
            throw MockMedicineDataServiceError.checkForDuplicateFailed
        }
        return medicines.contains { $0.name.lowercased() == name.lowercased() }
    }

    func removeMedicines(medicines: [Medicine]) async throws {
        if shouldThrowRemoveMedicinesError {
            throw MockMedicineDataServiceError.removeMedicinesFailed
        }
        for medicine in medicines {
            self.medicines.removeAll { $0.id == medicine.id }
        }
        // Simulate a listener update
        if let completion = medicinesCompletion {
            let sortedMedicines = self.medicines.sorted { $0.name < $1.name } // Simulate default sort by name
            completion(sortedMedicines)
        }
    }

    func modifyMedicine(_ medicine: Medicine, user: String, changes: [MedecineChangeRequest]) async throws {
        if shouldThrowModifyMedicineError {
            throw MockMedicineDataServiceError.modifyMedicineFailed
        }
        if let index = medicines.firstIndex(where: { $0.id == medicine.id }) {
            medicines[index] = medicine
        }
        let historyEntry = HistoryEntry(
            id: UUID().uuidString,
            medicineId: medicine.id ?? "",
            fullName: user,
            action: "Modified",
            details: changes.map { $0.description }.joined(separator: ", "),
            timestamp: Date()
        )
        history.append(historyEntry)
        // Simulate a listener update for medicines
        if let completion = medicinesCompletion {
            let sortedMedicines = self.medicines.sorted { $0.name < $1.name } // Simulate default sort by name
            completion(sortedMedicines)
        }
        // Simulate a listener update for history
        if let medicineId = medicine.id, let historyCompletion = historyCompletions[medicineId] {
            let filteredHistory = self.history.filter { $0.medicineId == medicineId }
            historyCompletion(filteredHistory)
        }
    }

    // Add a new medicine to the mock data
    func addMedicine(medicine: Medicine) async throws {
        if shouldThrowAddMedicineError {
            throw MockMedicineDataServiceError.addMedicineFailed
        }
        var newMedicine = medicine
        newMedicine.id = UUID().uuidString
        medicines.append(newMedicine)
        // Simulate a listener update
        if let completion = medicinesCompletion {
            let sortedMedicines = self.medicines.sorted { $0.name < $1.name } // Simulate default sort by name
            completion(sortedMedicines)
        }
    }

    // Stop all active listeners and clear completion handlers
    func stopListening() {
        isListening = false
        medicinesCompletion = nil
        historyCompletions.removeAll()
    }
}
extension MedecineChangeRequest {
    var description: String {
        switch self {
        case .nameChanged:
            return "Medicine name changed"
        case .stockChanged:
            return "Medicine stock changed"
        case .aisleChanged:
            return "Medicine aisle changed"
        }
    }
}
