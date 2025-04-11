//
//  MedicineDetailHeaderView.swift
//  MediStock
//
//  Created by Margot Pasquali on 11/04/2025.
//

import SwiftUI

struct MedicineDetailHeaderView: View {
    // MARK: - Constants
    let stockStatusColor: Color
    let isLowStock: Bool
    // MARK: - Properties
    @Binding var medicineName: String

    // MARK: - View
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "pills.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(stockStatusColor.opacity(isLowStock ? 1.0 : 0.5), .text)
                    .accessibilityHidden(true)

                TextField("Name", text: $medicineName)
                    .font(.custom("Righteous", size: 30))
                    .foregroundStyle(Color.text)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                    .padding(.bottom, 10)
                    .autocorrectionDisabled(true)
                    .accessibilityLabel("Nom du médicament")
                    .accessibilityValue(medicineName)
            }
            Spacer()
        }
    }
}

#Preview {
    MedicineDetailHeaderView(
        stockStatusColor: .alert,
        isLowStock: true,
        medicineName: .constant("Aspirin")
    )
}
