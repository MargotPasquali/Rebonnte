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
    private let pageSize = 12
    private var currentPage = 0

    // MARK: - Properties
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var sortOption: SortOption = .none
    @Published var canLoadMore: Bool = true
    private var allMedicines: [Medicine] = []
    @Published var medicines: [Medicine] = []
    @Published var displayedMedicines: [Medicine] = []

    var filteredMedicines: [Medicine] {
        var filtered = displayedMedicines

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
        currentPage = 0
        displayedMedicines.removeAll()

        Task {
            do {
                let fetchedMedicines = try await medicineDataService.retrieveMedicines()
                Task { @MainActor in
                    allMedicines = fetchedMedicines
                    self.medicines = allMedicines
                    loadMoreMedicines()
                }
            } catch {
                errorMessage = MedicineListViewModelError.failedToFetchMedicines.localizedDescription
            }
        }

        isLoading = false
    }

    func fetchMedicinesSortedByName() async {
        isLoading = true
        errorMessage = nil
        currentPage = 0
        displayedMedicines.removeAll()

        Task {
            do {
                let sortedMedicines = try await medicineDataService.retrieveMedicinesSortedByName()
                Task { @MainActor in
                    allMedicines = sortedMedicines
                    loadMoreMedicines()
                }
            } catch {
                errorMessage = MedicineListViewModelError.failedToFetchMedicineByName.localizedDescription
            }
        }

        isLoading = false
    }

    func fetchMedicinesSortedByStock() async {
        isLoading = true
        errorMessage = nil
        currentPage = 0
        displayedMedicines.removeAll()

        Task {
            do {
                let sortedMedicines = try await medicineDataService.retrieveMedicinesSortedByStock()
                Task { @MainActor in
                    allMedicines = sortedMedicines
                    loadMoreMedicines()
                }
            } catch {
                errorMessage = MedicineListViewModelError.failedToFetchMedicineByStock.localizedDescription
            }
        }
        isLoading = false
    }

    func loadMoreMedicines() {
        let start = currentPage * pageSize
        let end = start + pageSize
        if start < allMedicines.count {
            let newMedicines = Array(allMedicines[start..<min(end, allMedicines.count)])
            displayedMedicines.append(contentsOf: newMedicines)
            currentPage += 1
        }
        canLoadMore = displayedMedicines.count < allMedicines.count
    }
}
