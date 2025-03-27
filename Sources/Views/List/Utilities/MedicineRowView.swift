//
//  MedicineRowView.swift
//  MediStock
//
//  Created by Margot Pasquali on 26/03/2025.
//
import SwiftUI

struct MedicineRowView: View {
    let medicine: Medicine
    
    private let lowStockThreshold = 40
    
    private var stockStatusColor: Color {
        medicine.stock <= lowStockThreshold ? .alert : .success
    }
    
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
                Text(medicine.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.background)
                
                Text("Stock: \(medicine.stock)")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.background)
            }
        }
    }
}

#Preview {
    let sampleMedicine = Medicine(name: "Aspirin", stock: 5, aisle: "A1")
    return MedicineRowView(medicine: sampleMedicine)
}
