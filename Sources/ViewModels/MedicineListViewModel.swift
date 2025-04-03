import Foundation

@MainActor
final class MedicineListViewModel: ObservableObject {

    enum MedicineListViewModelError: Error {
        case failedToFetchMedicines
        case failedToFetchAisles
        case failedToUpdateMedicine
        case failedToAddMedicine
        case failedToDeleteMedicines
        case failedToFetchHistory

        var localizedDescription: String {
            switch self {
            case .failedToFetchMedicines:
                return "Failed to fetch medicines"
            case .failedToFetchAisles:
                return "Failed to fetch aisles"
            case .failedToUpdateMedicine:
                return "Failed to update medicine"
            case .failedToAddMedicine:
                return "Failed to add medicine"
            case .failedToDeleteMedicines:
                return "Failed to delete medicines"
            case .failedToFetchHistory:
                return "Failed to fetch history"
            }
        }
    }

    private let medicineDataService: MedicineDataService

    @Published var medicines: [Medicine] = []
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
            errorMessage = MedicineListViewModelError.failedToFetchMedicines.localizedDescription
        }

        isLoading = false
    }

    func increaseStock(_ medicine: Medicine, user: String) async {
        do {
            try await medicineDataService.adjustMedicineStock(medicine, by: 1, user: user)
            await fetchMedicines()
        } catch {
            errorMessage = MedicineListViewModelError.failedToUpdateMedicine.localizedDescription
        }
    }

    func decreaseStock(_ medicine: Medicine, user: String) async {
        do {
            try await medicineDataService.adjustMedicineStock(medicine, by: -1, user: user)
            await fetchMedicines()
        } catch {
            errorMessage = MedicineListViewModelError.failedToUpdateMedicine.localizedDescription
        }
    }

    func addRandomMedicine(user: String) async {
        do {
            try await medicineDataService.createRandomMedicine(user: user)
            await fetchMedicines()
        } catch {
            errorMessage = MedicineListViewModelError.failedToAddMedicine.localizedDescription
        }
    }

}
