import Foundation

class MedicineStockViewModel: ObservableObject {
    
    // MARK: - Enum
    enum MedecineStockViewModelError: Error {
        case failedToFetchMedicines
        
        var localizedDescription: String {
            switch self {
            case .failedToFetchMedicines:
                return "Failed to fetch medicines"
            }
        }
    }
    
    // MARK: - Constants
    private let medecineDataService: MedicineDataService
    
    // MARK: - Properties
    @Published var medicines: [Medicine] = []
    @Published var aisles = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    init(medicineDataService: MedicineDataService = RemoteMedicineDataService()) {
        self.medecineDataService = medicineDataService
    }
    
    // MARK: - Functions
    func increaseStock(_ medicine: Medicine, user: String) {
        medecineDataService.updateMedicine(medicine, by: 1, user: user)
    }
    
    func decreaseStock(_ medicine: Medicine, user: String) {
        medecineDataService.updateMedicine(medicine, by: -1, user: user)
    }
    
    func updateMedicines() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMedicines = try await medecineDataService.fetchMedicines()
            self.medicines = fetchedMedicines
        } catch {
            errorMessage = MedecineStockViewModelError.failedToFetchMedicines.localizedDescription
        }
        
        isLoading = false
    }
}
