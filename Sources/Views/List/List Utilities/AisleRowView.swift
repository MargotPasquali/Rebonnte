//
//  AisleRowView.swift
//  MediStock
//
//  Created by Margot Pasquali on 27/03/2025.
//

import SwiftUI

struct AisleRowView: View {
    let aisle: String

    var body: some View {
        HStack {
            Image("aisle")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.trailing)
            Text(aisle)
                .font(Font.custom("Nunito-Medium", size: 16))
                .foregroundStyle(Color.text)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.horizontal)
    }
}

#Preview {
    AisleRowView(aisle: "Aisle 1")
}
