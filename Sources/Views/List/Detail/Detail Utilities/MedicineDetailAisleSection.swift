//
//  MedicineDetailAisleSection.swift
//  MediStock
//
//  Created by Margot Pasquali on 11/04/2025.
//

import SwiftUI

struct MedicineDetailAisleSection: View {
    // MARK: - Properties
    @Binding var aisle: String

    // MARK: - View
    var body: some View {
        HStack {
            Text("Aisle")
                .font(.custom("Nunito-Bold", size: 18))
                .foregroundStyle(Color.background)
                .padding(.trailing)
                .accessibilityHidden(true)

            TextField("", text: $aisle, prompt: Text("0").foregroundColor(.gray))
                .font(.custom("Nunito-Bold", size: 18))
                .foregroundStyle(Color.background)
                .multilineTextAlignment(.leading)
                .accessibilityLabel("Allée du médicament")
                .accessibilityValue(aisle)
        }
        .padding()
        .background(Color.text)
        .cornerRadius(4)
    }
}

#Preview {
    MedicineDetailAisleSection(aisle: .constant("A1"))
}
