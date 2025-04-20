import Foundation

@MainActor
final class AisleListViewModel: ObservableObject {
    // MARK: - Error Enum
    enum AisleListViewModelError: LocalizedError {
        case failedToFetchAisles
        var errorDescription: String? { "Échec de la récupération des rayons." }
    }

    // MARK: - Constants
    private let medicineDataService: MedicineDataService
    
    // MARK: - Properties
    @Published var aisles: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Init
    init(medicineDataService: MedicineDataService = RemoteMedicineDataService()) {
        self.medicineDataService = medicineDataService
    }

    // MARK: - Functions
    func startObserving() {
        isLoading = true
        Task {
            medicineDataService.observeMedicinesWithoutSort { [weak self] medicines in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.aisles = Array(Set(medicines.map { $0.aisle })).sorted()
                    self.isLoading = false
                }
            }
        }
    }

    func stopObserving() {
        Task {
            medicineDataService.stopListening()
        }
    }
}
