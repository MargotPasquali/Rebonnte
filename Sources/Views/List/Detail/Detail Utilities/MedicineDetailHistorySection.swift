//
//  MedicineDetailHistorySection.swift
//  MediStock
//
//  Created by Margot Pasquali on 11/04/2025.
//

import SwiftUI

struct MedicineDetailHistorySection: View {
    // MARK: - Constants
    let history: [HistoryEntry]
    let medicineId: String?

    // MARK: - View
    var body: some View {
        if history.isEmpty {
            Text("No history available")
                .font(.custom("Nunito-Medium", size: 18))
                .foregroundStyle(Color.background)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.text)
                .cornerRadius(4)
                .accessibilityLabel("Aucun historique disponible")
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("History")
                    .font(.custom("Nunito-Bold", size: 18))
                    .foregroundStyle(Color.background)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Historique des modifications")

                ForEach(history.filter { $0.medicineId == medicineId }, id: \.id) { entry in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(entry.action)
                            .font(.custom("Nunito-SemiBold", size: 16))
                            .foregroundStyle(Color.background)
                        Text("User: \(entry.fullName)")
                            .font(.custom("Nunito-Regular", size: 16))
                            .foregroundStyle(Color.background)
                        Text("Date: \(entry.timestamp.formatted())")
                            .font(.custom("Nunito-Light", size: 16))
                            .foregroundStyle(Color.background)
                        Text("Details: \(entry.details)")
                            .font(.custom("Nunito-ExtraLight", size: 16))
                            .foregroundStyle(Color.background)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .accessibilityLabel("Modification : \(entry.action), par \(entry.fullName), le \(entry.timestamp.formatted()), détails : \(entry.details)")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.text)
            .cornerRadius(4)
        }
    }
}

#Preview {
    MedicineDetailHistorySection(
        history: [
            HistoryEntry(
                id: "1",
                medicineId: "1",
                fullName: "Jean Dupont",
                action: "Updated Aspirin",
                details: "Stock changed",
                timestamp: Date()
            )
        ],
        medicineId: "1"
    )
}
