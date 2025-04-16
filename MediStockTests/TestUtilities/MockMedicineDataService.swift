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
        case fetchMedicinesFailed
        case fetchMedicinesSortedByNameFailed
        case fetchMedicinesSortedByStockFailed
        case checkForDuplicateFailed
        case fetchAislesFailed
        case removeMedicinesFailed
        case modifyMedicineFailed
        case fetchHistoryFailed
        case addMedicineFailed
        
        var localizedDescription: String {
            switch self {
            case .fetchMedicinesFailed:
                return "Failed to fetch medicines."
            case .fetchMedicinesSortedByNameFailed:
                return "Failed to fetch medicines sorted by name."
            case .fetchMedicinesSortedByStockFailed:
                return "Failed to fetch medicines sorted by stock."
            case .checkForDuplicateFailed:
                return "Failed to check for duplicate medicine."
            case .fetchAislesFailed:
                return "Failed to fetch aisles."
            case .removeMedicinesFailed:
                return "Failed to remove medicines."
            case .modifyMedicineFailed:
                return "Failed to modify medicine."
            case .fetchHistoryFailed:
                return "Failed to fetch history."
            case .addMedicineFailed:
                return "Failed to add medicine."
            }
        }
    }
    
    // MARK: - Properties
    var medicines: [Medicine] = []
    var history: [HistoryEntry] = []
    var aisles: [String] = []
    
    var shouldThrowFetchMedicinesError = false
    var shouldThrowFetchMedicinesSortedByNameError = false
    var shouldThrowFetchMedicinesSortedByStockError = false
    var shouldThrowCheckForDuplicateError = false
    var shouldThrowFetchAislesError = false
    var shouldThrowRemoveMedicinesError = false
    var shouldThrowModifyMedicineError = false
    var shouldThrowFetchHistoryError = false
    var shouldThrowAddMedicineError = false
    
    // MARK: - Init with default data
    init(medicines: [Medicine] = [
        Medicine(id: "testMedicineID1", name: "Aspirin", stock: 50, aisle: "A1"),
        Medicine(id: "testMedicineID2", name: "Paracetamol", stock: 30, aisle: "B2")
    ], history: [HistoryEntry] = [
        HistoryEntry(id: "history1", medicineId: "testMedicineID1", fullName: "Test User", action: "Added", details: "Added medicine", timestamp: Date())
    ], aisles: [String] = ["A1", "B2"]) {
        self.medicines = medicines
        self.history = history
        self.aisles = aisles
    }
    
    // MARK: - Functions
    func retrieveMedicines() async throws -> [Medicine] {
        if shouldThrowFetchMedicinesError {
            throw MockMedicineDataServiceError.fetchMedicinesFailed
        }
        return medicines
    }
    
    func retrieveMedicinesSortedByName() async throws -> [Medicine] {
        if shouldThrowFetchMedicinesSortedByNameError {
            throw MockMedicineDataServiceError.fetchMedicinesSortedByNameFailed
        }
        return medicines.sorted { $0.name < $1.name }
    }
    
    func retrieveMedicinesSortedByStock() async throws -> [Medicine] {
        if shouldThrowFetchMedicinesSortedByStockError {
            throw MockMedicineDataServiceError.fetchMedicinesSortedByStockFailed
        }
        return medicines.sorted { $0.stock < $1.stock }
    }
    
    func checkForDuplicate(name: String) async throws -> Bool {
        if shouldThrowCheckForDuplicateError {
            throw MockMedicineDataServiceError.checkForDuplicateFailed
        }
        return medicines.contains { $0.name.lowercased() == name.lowercased() }
    }
    
    func retrieveAisles() async throws -> [String] {
        if shouldThrowFetchAislesError {
            throw MockMedicineDataServiceError.fetchAislesFailed
        }
        return aisles
    }
    
    func removeMedicines(medicines: [Medicine]) async throws {
        if shouldThrowRemoveMedicinesError {
            throw MockMedicineDataServiceError.removeMedicinesFailed
        }
        for medicine in medicines {
            self.medicines.removeAll { $0.id == medicine.id }
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
    }
    
    func retrieveMedicineHistory(for medicine: Medicine) async throws -> [HistoryEntry] {
        if shouldThrowFetchHistoryError {
            throw MockMedicineDataServiceError.fetchHistoryFailed
        }
        return history.filter { $0.medicineId == medicine.id }
    }
    
    func addMedicine(medicine: Medicine) async throws {
        if shouldThrowAddMedicineError {
            throw MockMedicineDataServiceError.addMedicineFailed
        }
        var newMedicine = medicine
        newMedicine.id = UUID().uuidString
        medicines.append(newMedicine)
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
