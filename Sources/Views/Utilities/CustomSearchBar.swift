//
//  CustomSearchBar.swift
//  MediStock
//
//  Created by Margot Pasquali on 07/04/2025.
//

import SwiftUI

struct CustomSearchBar: View {
    // MARK: - Properties
    @ObservedObject var viewModel: MedicineListViewModel

    // MARK: - View
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.background)
                .frame(width: 20, height: 20)

            TextField("Filter by name...", text: $viewModel.searchText, prompt: Text("Filter by name...").foregroundColor(.background))
                .foregroundColor(.background)
                .font(Font.custom("Nunito-Regular", size: 16))
                .textInputAutocapitalization(.never)
                .submitLabel(.search)

            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.background)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.text)
        .cornerRadius(4)
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

#Preview {
    CustomSearchBar(viewModel: MedicineListViewModel())
}
