import Foundation
import FirebaseFirestore

@MainActor
final class MedicineListViewModel: ObservableObject {
    // MARK: - Error Enum
    enum MedicineListViewModelError: Error {
        case failedToFetchMedicines
        var localizedDescription: String { "Échec de la récupération des médicaments" }
    }

    // MARK: - Constants
    private let medicineDataService: MedicineDataService

    // MARK: - Properties
    @Published var isObserving: Bool = false
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var sortOption: SortOption = .name
    @Published var medicines: [Medicine] = []

    var filteredMedicines: [Medicine] {
        var filtered = medicines
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        return filtered
    }

    // MARK: - Init
    init(medicineDataService: MedicineDataService = RemoteMedicineDataService()) {
        self.medicineDataService = medicineDataService
    }

    // MARK: - Functions
    func startObserving() {
        guard !isObserving else { return }
        isObserving = true
        isLoading = true
        Task {
            medicineDataService.observeMedicines(sortOption: sortOption) { [weak self] medicines in
                Task { @MainActor in
                    self?.medicines = medicines
                    self?.isLoading = false
                }
            }
        }
    }

    func stopObserving() {
        Task {
            medicineDataService.stopListening()
        }
        isObserving = false
    }
}
