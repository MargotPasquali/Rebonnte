import Foundation

@MainActor
final class MedicineDetailViewModel: ObservableObject {
    // MARK: - Error Enum
    enum MedicineDetailViewModelError: LocalizedError {
        case failedToDeleteMedicines
        case failedToModifyMedicine
        var errorDescription: String? {
            switch self {
            case .failedToDeleteMedicines: return "Échec de la suppression des médicaments."
            case .failedToModifyMedicine: return "Échec de la modification du médicament."
            }
        }
    }

    // MARK: - Constants
    private let medicineDataService: MedicineDataService
    
    // MARK: - Properties
    @Published var medicines: [Medicine] = []
    @Published var history: [HistoryEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Init
    init(medicineDataService: MedicineDataService = RemoteMedicineDataService()) {
        self.medicineDataService = medicineDataService
    }
    // MARK: - Functions
    func startObservingMedicines() {
        isLoading = true
        Task {
            medicineDataService.observeMedicinesWithoutSort { [weak self] medicines in
                Task { @MainActor in
                    self?.medicines = medicines
                    self?.isLoading = false
                }
            }
        }
    }

    func observeHistory(for medicine: Medicine) {
        Task {
            medicineDataService.observeMedicineHistory(for: medicine) { [weak self] history in
                Task { @MainActor in
                    self?.history = history
                }
            }
        }
    }

    func stopObserving() {
        Task {
            medicineDataService.stopListening()
        }
    }

    func deleteMedicines(at offsets: IndexSet) async {
        let medicinesToDelete = offsets.map { medicines[$0] }
        Task {
            do {
                try await medicineDataService.removeMedicines(medicines: medicinesToDelete)
            } catch {
                errorMessage = MedicineDetailViewModelError.failedToDeleteMedicines.errorDescription
            }
        }
    }

    func modifyMedicine(_ medicine: Medicine, user: String, changes: [MedecineChangeRequest]) async {
        Task {
            do {
                try await medicineDataService.modifyMedicine(medicine, user: user, changes: changes)
            } catch {
                errorMessage = MedicineDetailViewModelError.failedToModifyMedicine.errorDescription
            }
        }
    }
}
