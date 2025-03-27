import Foundation

@MainActor
final class MedicineStockViewModel: ObservableObject {
    
    enum MedicineStockViewModelError: Error {
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
    @Published var aisles: [String] = []
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
            errorMessage = MedicineStockViewModelError.failedToFetchMedicines.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchAisles() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedAisles = try await medicineDataService.retrieveAisles()
            self.aisles = fetchedAisles
        } catch {
            errorMessage = MedicineStockViewModelError.failedToFetchAisles.localizedDescription
        }
        
        isLoading = false
    }
    
    func increaseStock(_ medicine: Medicine, user: String) async {
        do {
            try await medicineDataService.adjustMedicineStock(medicine, by: 1, user: user)
            await fetchMedicines()
        } catch {
            errorMessage = MedicineStockViewModelError.failedToUpdateMedicine.localizedDescription
        }
    }
    
    func decreaseStock(_ medicine: Medicine, user: String) async {
        do {
            try await medicineDataService.adjustMedicineStock(medicine, by: -1, user: user)
            await fetchMedicines()
        } catch {
            errorMessage = MedicineStockViewModelError.failedToUpdateMedicine.localizedDescription
        }
    }
    
    func addRandomMedicine(user: String) async {
        do {
            try await medicineDataService.createRandomMedicine(user: user)
            await fetchMedicines()
        } catch {
            errorMessage = MedicineStockViewModelError.failedToAddMedicine.localizedDescription
        }
    }
    
    func deleteMedicines(at offsets: IndexSet) async {
        let medicinesToDelete = offsets.map { medicines[$0] }
        do {
            try await medicineDataService.removeMedicines(medicines: medicinesToDelete)
            await fetchMedicines()
        } catch {
            errorMessage = MedicineStockViewModelError.failedToDeleteMedicines.localizedDescription
        }
    }
    
    func fetchHistory(for medicine: Medicine) async {
        do {
            let fetchedHistory = try await medicineDataService.retrieveMedicineHistory(for: medicine)
            self.history = fetchedHistory
        } catch {
            errorMessage = MedicineStockViewModelError.failedToFetchHistory.localizedDescription
        }
    }
    
    func modifyMedicine(_ medicine: Medicine, user: String) async {
        do {
            try await medicineDataService.modifyMedicine(medicine, user: user)
            await fetchMedicines()
        } catch {
            errorMessage = MedicineStockViewModelError.failedToUpdateMedicine.localizedDescription
        }
    }
}
