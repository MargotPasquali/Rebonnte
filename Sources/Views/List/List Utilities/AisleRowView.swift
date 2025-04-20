//
//  AisleRowView.swift
//  MediStock
//
//  Created by Margot Pasquali on 27/03/2025.
//

import SwiftUI

struct AisleRowView: View {
    // MARK: - Constants
    let aisle: String

    // MARK: - View
    var body: some View {
        HStack {
            Image("aisle")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.trailing)
                .accessibilityHidden(true)

            Text(aisle)
                .font(Font.custom("Nunito-Medium", size: 16))
                .foregroundStyle(Color.text)

            Spacer()

            Image(systemName: "chevron.right")
                .accessibilityHidden(true)
        }
        .padding(.horizontal)
        .accessibilityLabel("Allée \(aisle), bouton")
    }
}

#Preview {
    AisleRowView(aisle: "Aisle 1")
}
