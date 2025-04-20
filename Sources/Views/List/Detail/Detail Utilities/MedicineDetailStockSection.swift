//
//  MedicineDetailStockSection.swift
//  MediStock
//
//  Created by Margot Pasquali on 11/04/2025.
//

import SwiftUI

struct MedicineDetailStockSection: View {
    // MARK: - Constants
    let stockStatusColor: Color
    // MARK: - Properties
    @Binding var stock: Double

    // MARK: - View
    var body: some View {
        HStack {
            Text("Stock")
                .font(.custom("Nunito-Bold", size: 18))
                .foregroundStyle(Color.background)
                .padding(.trailing)
                .accessibilityHidden(true)

            Slider(value: $stock, in: 0...100, step: 5) {
                Text("Stock: \(Int(stock), specifier: "%.0f")")
            }
            .tint(stock < 50 ? .alert : .success)
            .accessibilityLabel("Stock du médicament")
            .accessibilityValue("\(Int(stock))")

            Text("\(Int(stock))")
                .font(.custom("Nunito-Bold", size: 16))
                .foregroundStyle(Color.background)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityHidden(true)
        }
        .padding()
        .background(Color.text)
        .cornerRadius(4)
    }
}

#Preview {
    MedicineDetailStockSection(stockStatusColor: .success, stock: .constant(50))
}
