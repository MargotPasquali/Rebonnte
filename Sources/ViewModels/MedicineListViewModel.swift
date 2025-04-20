import Foundation

@MainActor
final class MedicineListViewModel: ObservableObject {

    // MARK: - Error Enum
    enum MedicineListViewModelError: Error {
        case failedToFetchMedicines
        case failedToFetchMedicineByName
        case failedToFetchMedicineByStock

        var localizedDescription: String {
            switch self {
            case .failedToFetchMedicines:
                return "Failed to fetch medicines"
            case .failedToFetchMedicineByName:
                return "Failed to fetch medicine by name"
            case .failedToFetchMedicineByStock:
                return "Failed to fetch medicine by stock"
            }
        }
    }

    // MARK: - Constants
    private let medicineDataService: MedicineDataService

    // MARK: - Properties
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
            return filtered
        }

    // MARK: - Init
    init(medicineDataService: MedicineDataService = RemoteMedicineDataService()) {
        self.medicineDataService = medicineDataService
    }

    // MARK: - Functions
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

    func fetchMedicinesSortedByName() async {
            isLoading = true
            errorMessage = nil

            do {
                let sortedMedicines = try await medicineDataService.retrieveMedicinesSortedByName()
                self.medicines = sortedMedicines
            } catch {
                errorMessage = MedicineListViewModelError.failedToFetchMedicineByName.localizedDescription
            }

            isLoading = false
        }

    func fetchMedicinesSortedByStock() async {
            isLoading = true
            errorMessage = nil

            do {
                let sortedMedicines = try await medicineDataService.retrieveMedicinesSortedByStock()
                self.medicines = sortedMedicines
            } catch {
                errorMessage = MedicineListViewModelError.failedToFetchMedicineByStock.localizedDescription
            }

            isLoading = false
        }
}
