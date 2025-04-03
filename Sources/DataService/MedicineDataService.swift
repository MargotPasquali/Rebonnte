import Foundation
import FirebaseFirestore

protocol MedicineDataService {
    func retrieveMedicines() async throws -> [Medicine]
    func retrieveAisles() async throws -> [String]
    func createRandomMedicine(user: String) async throws
    func removeMedicines(medicines: [Medicine]) async throws
    func adjustMedicineStock(_ medicine: Medicine, by amount: Int, user: String) async throws
    func modifyMedicine(_ medicine: Medicine, user: String) async throws
    func retrieveMedicineHistory(for medicine: Medicine) async throws -> [HistoryEntry]
    func addMedicine(medicine: Medicine) async throws
}

final class RemoteMedicineDataService: MedicineDataService {
    private let data = Firestore.firestore()

    func retrieveMedicines() async throws -> [Medicine] {
        let snapshot = try await data.collection("medicines").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Medicine.self)
        }
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

    func createRandomMedicine(user: String) async throws {
        let medicine = Medicine(name: "Medicine \(Int.random(in: 1...100))",
                              stock: Int.random(in: 1...100),
                              aisle: "Aisle \(Int.random(in: 1...10))")
        try await data.collection("medicines")
            .document(medicine.id ?? UUID().uuidString)
            .setData(from: medicine)
        try await recordHistory(action: "Added \(medicine.name)",
                              user: user,
                              medicineId: medicine.id ?? "",
                              details: "Added new medicine")
    }

    func removeMedicines(medicines: [Medicine]) async throws {
        for medicine in medicines {
            if let id = medicine.id {
                try await data.collection("medicines").document(id).delete()
            }
        }
    }

    func adjustMedicineStock(_ medicine: Medicine, by amount: Int, user: String) async throws {
        guard let id = medicine.id else { return }
        let newStock = medicine.stock + amount
        try await data.collection("medicines").document(id).updateData([
            "stock": newStock
        ])
        try await recordHistory(action: "\(amount > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(abs(amount))",
                              user: user,
                              medicineId: id,
                              details: "Stock changed from \(medicine.stock) to \(newStock)")
    }

    func modifyMedicine(_ medicine: Medicine, user: String) async throws {
        guard let id = medicine.id else { return }
        try await data.collection("medicines").document(id).setData(from: medicine)
        try await recordHistory(action: "Updated \(medicine.name)",
                              user: user,
                              medicineId: id,
                              details: "Updated medicine details")
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
        let history = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
        try await data.collection("history")
            .document(history.id ?? UUID().uuidString)
            .setData(from: history)
    }
    
    func addMedicine(medicine: Medicine) async throws {
        let _ = try await data.collection("medicines").addDocument(from: medicine)
    }
}
