//
//  AisleListViewModel.swift
//  MediStock
//
//  Created by Margot Pasquali on 02/04/2025.
//

import Foundation

@MainActor
final class AisleListViewModel: ObservableObject {

    enum AisleListViewModelError: LocalizedError {
        case failedToFetchAisles

        var errorDescription: String? {
            switch self {
            case .failedToFetchAisles:
                return "Failed to fetch aisle list."
            }
        }
    }

    private let medicineDataService: MedicineDataService

    @Published var aisles: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(medicineDataService: MedicineDataService = RemoteMedicineDataService()) {
        self.medicineDataService = medicineDataService
    }

    func fetchAisles() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedAisles = try await medicineDataService.retrieveAisles()
            self.aisles = fetchedAisles
        } catch {
            errorMessage = AisleListViewModelError.failedToFetchAisles.localizedDescription
        }

        isLoading = false
    }
}
