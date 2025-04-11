//
//  AddNewMedicineViewModel.swift
//  MediStock
//
//  Created by Margot Pasquali on 02/04/2025.
//

import Foundation

@MainActor
final class AddNewMedicineViewModel: ObservableObject {

    // MARK: - Error Enum
    enum AddNewMedicineError: Error {
        case failedToAddNewMedicine
        case medicineAlreadyExists
        case failedToUpdateExistingMedicine
        case failedToModifyMedicine
        case invalidData

        var localizedDescription: String {
            switch self {
            case .failedToAddNewMedicine:
                return "Failed to add new medicine."
            case .medicineAlreadyExists:
                return "Medicine already exists."
            case .failedToUpdateExistingMedicine:
                return "Failed to update existing medicine."
            case .failedToModifyMedicine:
                return "Failed to modify medicine."
            case .invalidData:
                return "Invalid data provided."
            }
        }
    }

    // MARK: - Constants
    private let medicineDataService: MedicineDataService

    // MARK: - Properties
    @Published var name: String = ""
    @Published var stock: Int = 0
    @Published var aisle: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Init
    init(medicineDataService: MedicineDataService = RemoteMedicineDataService()) {
        self.medicineDataService = medicineDataService
    }

    // MARK: - Functions
    func addNewMedecine() async {
        guard !name.isEmpty, !aisle.isEmpty else {
            errorMessage = AddNewMedicineError.invalidData.localizedDescription
            return
        }
        guard stock > 0 && stock <= 100 else {
            errorMessage = AddNewMedicineError.invalidData.localizedDescription
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let exists = try await medicineDataService.checkForDuplicate(name: name)
            guard !exists else {
                errorMessage = AddNewMedicineError.medicineAlreadyExists.localizedDescription
                isLoading = false
                return
            }
        } catch {
            errorMessage = AddNewMedicineError.failedToAddNewMedicine.localizedDescription
            isLoading = false
            return
        }

        let newMedicine = Medicine(
            id: nil,
            name: name,
            stock: stock,
            aisle: aisle
        )

        do {
            try await medicineDataService.addMedicine(medicine: newMedicine)
            errorMessage = nil
            resetFields()
        } catch {
            errorMessage = AddNewMedicineError.failedToAddNewMedicine.localizedDescription
        }
        isLoading = false
    }

    private func resetFields() {
        name = ""
        stock = 0
        aisle = ""
    }
}
