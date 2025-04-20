import FirebaseFirestore

// MARK: - Protocol
protocol MedicineDataService {
    func observeMedicines(sortOption: SortOption, completion: @escaping ([Medicine]) -> Void)
    func observeMedicinesWithoutSort(completion: @escaping ([Medicine]) -> Void)
    func observeMedicineHistory(for medicine: Medicine, completion: @escaping ([HistoryEntry]) -> Void)
    func checkForDuplicate(name: String) async throws -> Bool
    func removeMedicines(medicines: [Medicine]) async throws
    func modifyMedicine(_ medicine: Medicine, user: String, changes: [MedecineChangeRequest]) async throws
    func addMedicine(medicine: Medicine) async throws
    func stopListening()
}

final class RemoteMedicineDataService: MedicineDataService {
    // MARK: - Constants
    private let data = Firestore.firestore()
    private var medicineListener: ListenerRegistration?
    private var historyListeners: [String: ListenerRegistration] = [:]

    // MARK: - Functions
    func observeMedicines(sortOption: SortOption, completion: @escaping ([Medicine]) -> Void) {
        var query: Query = data.collection("medicines")

        switch sortOption {
        case .name:
            query = query.order(by: "name")
        case .stock:
            query = query.order(by: "stock")
        }

        medicineListener?.remove()

        medicineListener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Erreur lors de la récupération des médicaments : \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let medicines = snapshot.documents.compactMap { try? $0.data(as: Medicine.self) }
            completion(medicines)
        }
    }

    func observeMedicinesWithoutSort(completion: @escaping ([Medicine]) -> Void) {
            medicineListener?.remove()
            medicineListener = data.collection("medicines").addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Erreur : \(error.localizedDescription)")
                    return
                }
                guard let snapshot = snapshot else { return }
                let medicines = snapshot.documents.compactMap { try? $0.data(as: Medicine.self) }
                completion(medicines)
            }
        }
    
    func checkForDuplicate(name: String) async throws -> Bool {
        let snapshot = try await data.collection("medicines")
            .whereField("name", isEqualTo: name)
            .getDocuments()
        return !snapshot.documents.isEmpty
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
        try await data.collection("medicines").document(id).setData(from: medicine)
        let changeMessages = changes.map { change in
            switch change {
            case .nameChanged: return "Nom du médicament modifié"
            case .stockChanged: return "Stock du médicament modifié"
            case .aisleChanged: return "Rayon du médicament modifié"
            }
        }
        let details = changeMessages.joined(separator: ", ")
        try await recordHistory(action: "Modification de \(medicine.name)", user: user, medicineId: id, details: details)
    }

    func observeMedicineHistory(for medicine: Medicine, completion: @escaping ([HistoryEntry]) -> Void) {
        guard let medicineId = medicine.id else {
            completion([])
            return
        }
        if historyListeners[medicineId] == nil {
            let listener = data.collection("history")
                .whereField("medicineId", isEqualTo: medicineId)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        print("Erreur lors de la récupération de l'historique : \(error?.localizedDescription ?? "Erreur inconnue")")
                        return
                    }
                    let history = snapshot.documents.compactMap { try? $0.data(as: HistoryEntry.self) }
                    completion(history)
                }
            historyListeners[medicineId] = listener
        }
    }

    func addMedicine(medicine: Medicine) async throws {
        _ = try await data.collection("medicines").addDocument(from: medicine)
    }

    func stopListening() {
        medicineListener?.remove()
        medicineListener = nil
        historyListeners.values.forEach { $0.remove() }
        historyListeners.removeAll()
    }

    private func recordHistory(action: String, user: String, medicineId: String, details: String) async throws {
        let userDoc = try await data.collection("users").document(user).getDocument()
        let fullName = userDoc.data()?["full_name"] as? String ?? "Utilisateur inconnu"
        let history = HistoryEntry(medicineId: medicineId, fullName: fullName, action: action, details: details)
        try await data.collection("history").document(history.id ?? UUID().uuidString).setData(from: history)
    }
}
