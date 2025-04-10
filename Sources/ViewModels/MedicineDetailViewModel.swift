//
//  MedicineDetailViewModel.swift
//  MediStock
//
//  Created by Margot Pasquali on 02/04/2025.
//

import Foundation

@MainActor
final class MedicineDetailViewModel: ObservableObject {

    enum MedicineDetailViewModelError: LocalizedError {
        case failedToFetchMedicines
        case failedToDeleteMedicines
        case failedToModifyMedicine
        case failedToFetchHistory

        var errorDescription: String? {
            switch self {
            case .failedToFetchMedicines:
                return "Failed to fetch medicines."
            case .failedToDeleteMedicines:
                return "Failed to delete medicines."
            case .failedToModifyMedicine:
                return "Failed to modify medicine."
            case .failedToFetchHistory:
                return "Failed to fetch history."
            }
        }
    }

    private let medicineDataService: MedicineDataService

    @Published var medicines: [Medicine] = []
    @Published var history: [HistoryEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(medicineDataService: MedicineDataService = RemoteMedicineDataService()) {
        self.medicineDataService = medicineDataService
    }

    func fetchMedicines() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedMedicines = try await medicineDataService.retrieveMedicines()
            self.medicines = fetchedMedicines
        } catch {
            errorMessage = MedicineDetailViewModelError.failedToFetchMedicines.localizedDescription
        }

        isLoading = false
    }

    func deleteMedicines(at offsets: IndexSet) async {
        let medicinesToDelete = offsets.map { medicines[$0] }
        do {
            try await medicineDataService.removeMedicines(medicines: medicinesToDelete)
            await fetchMedicines()
        } catch {
            errorMessage = MedicineDetailViewModelError.failedToDeleteMedicines.localizedDescription
        }
    }

    func modifyMedicine(_ medicine: Medicine, user: String, changes: [MedecineChangeRequest]) async {
            do {
                try await medicineDataService.modifyMedicine(medicine, user: user, changes: changes)
            } catch {
                print("Erreur lors de la modification : \(error)")
            }
        }

    func fetchHistory(for medicine: Medicine) async {
        do {
            let fetchedHistory = try await medicineDataService.retrieveMedicineHistory(for: medicine)
            self.history = fetchedHistory
        } catch {
            errorMessage = MedicineDetailViewModelError.failedToFetchHistory.localizedDescription
        }
    }
}
