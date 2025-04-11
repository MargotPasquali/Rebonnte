//
//  MedicineRowView.swift
//  MediStock
//
//  Created by Margot Pasquali on 26/03/2025.
//

import SwiftUI

struct MedicineRowView: View {
    // MARK: - Constants
    let medicine: Medicine
    private let lowStockThreshold = 40

    // MARK: - Properties
    private var stockStatusColor: Color {
        medicine.stock <= lowStockThreshold ? .alert : .success
    }

    // MARK: - View
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.text)
                .frame(width: 120, height: 120)

            VStack(spacing: 8) {
                Image(systemName: "pills.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(stockStatusColor)
                    .opacity(medicine.stock <= lowStockThreshold ? 1.0 : 0.3)
                    .accessibilityHidden(true)

                Text(medicine.name)
                    .font(Font.custom("Nunito-SemiBold", size: 16))
                    .foregroundStyle(Color.background)

                Text("Stock: \(medicine.stock)")
                    .font(Font.custom("Nunito-Medium", size: 14))
                    .foregroundStyle(Color.background)
            }
        }
        .accessibilityLabel("\(medicine.name), stock \(medicine.stock)\(medicine.stock <= lowStockThreshold ? ", faible stock" : "")")
    }
}

#Preview {
    let sampleMedicine = Medicine(name: "Aspirin", stock: 5, aisle: "A1")
    return MedicineRowView(medicine: sampleMedicine)
}
