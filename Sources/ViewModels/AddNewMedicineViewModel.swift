//
//  AddNewMedicineViewModel.swift
//  MediStock
//
//  Created by Margot Pasquali on 02/04/2025.
//

import Foundation

@MainActor
final class AddNewMedicineViewModel: ObservableObject {

    enum AddNewMedicineError: Error {
        case failedToAddNewMedicine
        case failedToUpdateExistingMedicine
        case failedToModifyMedicine
        case invalidData

        var localizedDescription: String {
            switch self {
            case .failedToAddNewMedicine:
                return "Failed to add new medicine."
            case .failedToUpdateExistingMedicine:
                return "Failed to update existing medicine."
            case .failedToModifyMedicine:
                return "Failed to modify medicine."
            case .invalidData:
                return "Invalid data provided."
            }
        }
    }

    private let medicineDataService: MedicineDataService

    @Published var name: String = ""
    @Published var stock: Int = 0
    @Published var aisle: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(medicineDataService: MedicineDataService = RemoteMedicineDataService()) {
        self.medicineDataService = medicineDataService
    }

    func addNewMedecine() async {
        guard !name.isEmpty, !aisle.isEmpty else {
            errorMessage = AddNewMedicineError.invalidData.localizedDescription
            return
        }

        let newMedicine = Medicine(
            id: nil,
            name: name,
            stock: stock,
            aisle: aisle
        )
        isLoading = true

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
