import Foundation

@MainActor
final class MedicineListViewModel: ObservableObject {

    enum MedicineListViewModelError: Error {
        case failedToFetchMedicines

        var localizedDescription: String {
            switch self {
            case .failedToFetchMedicines:
                return "Failed to fetch medicines"
            }
        }
    }

    private let medicineDataService: MedicineDataService

    @Published var medicines: [Medicine] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var sortOption: SortOption = .none
    var filteredMedicines: [Medicine] {
            var filtered = medicines

        if !searchText.isEmpty {
                filtered = filtered.filter { medicine in
                    let search = searchText.lowercased()
                    return medicine.name.lowercased().contains(search)
                }
            }

            switch sortOption {
            case .name:
                filtered.sort { $0.name.lowercased() < $1.name.lowercased() }
            case .stock:
                filtered.sort { $0.stock < $1.stock }
            case .none:
                break
            }

            return filtered
        }

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
            errorMessage = MedicineListViewModelError.failedToFetchMedicines.localizedDescription
        }

        isLoading = false
    }

}
