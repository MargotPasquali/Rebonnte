import Foundation
import FirebaseFirestoreSwift

struct HistoryEntry: Identifiable, Codable {
    // MARK: - Properties
    @DocumentID var id: String?
    var medicineId: String
    var fullName: String
    var action: String
    var details: String
    var timestamp: Date

    // MARK: - Init
    init(id: String? = nil, medicineId: String, fullName: String, action: String, details: String, timestamp: Date = Date()) {
        self.id = id
        self.medicineId = medicineId
        self.fullName = fullName
        self.action = action
        self.details = details
        self.timestamp = timestamp
    }

    // MARK: - Codings keys
    enum CodingKeys: String, CodingKey {
        case id
        case medicineId
        case fullName
        case action
        case details
        case timestamp
    }
}
