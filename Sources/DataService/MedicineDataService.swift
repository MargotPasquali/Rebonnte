import Foundation
import FirebaseFirestore

// MARK: - Protocol
protocol MedicineDataService {
    func retrieveMedicines() async throws -> [Medicine]
    func retrieveMedicinesSortedByName() async throws -> [Medicine]
    func retrieveMedicinesSortedByStock() async throws -> [Medicine]
    func checkForDuplicate(name: String) async throws -> Bool
    func retrieveAisles() async throws -> [String]
    func removeMedicines(medicines: [Medicine]) async throws
    func modifyMedicine(_ medicine: Medicine, user: String, changes: [MedecineChangeRequest]) async throws
    func retrieveMedicineHistory(for medicine: Medicine) async throws -> [HistoryEntry]
    func addMedicine(medicine: Medicine) async throws
}

final class RemoteMedicineDataService: MedicineDataService {
    // MARK: - Constants
    private let data = Firestore.firestore()

    // MARK: - Functions
    func retrieveMedicines() async throws -> [Medicine] {
        let snapshot = try await data.collection("medicines").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Medicine.self)
        }
    }

    func retrieveMedicinesSortedByName() async throws -> [Medicine] {
        let snapshot = try await data.collection("medicines")
            .order(by: "name")
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Medicine.self)
        }
    }

    func retrieveMedicinesSortedByStock() async throws -> [Medicine] {
        let snapshot = try await data.collection("medicines")
            .order(by: "stock", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Medicine.self)
        }
    }

    func checkForDuplicate(name: String) async throws -> Bool {
            let snapshot = try await data.collection("medicines")
                .whereField("name", isEqualTo: name)
                .getDocuments()
            return !snapshot.documents.isEmpty
        }

    func retrieveAisles() async throws -> [String] {
        print("Starting retrieveAisles at \(Date())")
        let snapshot = try await data.collection("medicines").getDocuments()
        let allMedicines = snapshot.documents.compactMap { document in
            try? document.data(as: Medicine.self)
        }
        let aisles = Array(Set(allMedicines.map { $0.aisle })).sorted()
        print("Finished retrieveAisles with \(aisles.count) aisles at \(Date())")
        return aisles
    }

    func removeMedicines(medicines: [Medicine]) async throws {
        for medicine in medicines {
            if let id = medicine.id {
                try await data.collection("medicines").document(id).delete()
            }
        }
    }

    func modifyMedicine(_ medicine: Medicine, user: String, changes: [MedecineChangeRequest]) async throws {
            guard let id = medicine.id else { return }

            // Save medicine in Firestore
            try await data.collection("medicines").document(id).setData(from: medicine)

            let changeMessages = changes.map { change in
                switch change {
                case .nameChanged:
                    return "Medicine name changed"
                case .stockChanged:
                    return "Medicine stock changed"
                case .aisleChanged:
                    return "Medicine aisle changed"
                }
            }
            let details = changeMessages.joined(separator: ", ")

            try await recordHistory(action: "Modification de \(medicine.name)", user: user, medicineId: id, details: details)
        }

    func retrieveMedicineHistory(for medicine: Medicine) async throws -> [HistoryEntry] {
        guard let medicineId = medicine.id else { return [] }
        let snapshot = try await data.collection("history")
            .whereField("medicineId", isEqualTo: medicineId)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: HistoryEntry.self)
        }
    }

    private func recordHistory(action: String, user: String, medicineId: String, details: String) async throws {
            let userDoc = try await data.collection("users").document(user).getDocument()
            let fullName = userDoc.data()?["full_name"] as? String ?? "Utilisateur inconnu"
            let history = HistoryEntry(medicineId: medicineId, fullName: fullName, action: action, details: details)
            try await data.collection("history").document(history.id ?? UUID().uuidString).setData(from: history)
        }

    func addMedicine(medicine: Medicine) async throws {
        let _ = try await data.collection("medicines").addDocument(from: medicine)
    }
}
