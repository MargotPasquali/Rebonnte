//
//  LoadMoreButton.swift
//  MediStock
//
//  Created by Margot Pasquali on 14/04/2025.
//

import SwiftUI

struct LoadMoreButton: View {
    // MARK: - Properties
    @EnvironmentObject var viewModel: MedicineListViewModel
    @State private var isLoadingMore = false

    // MARK: - View
    var body: some View {
        Button(action: {
            Task {
                isLoadingMore = true
                viewModel.loadMoreMedicines()
                isLoadingMore = false
            }
        }) {
            if isLoadingMore {
                ProgressView()
            } else {
                HStack {
                    Text("Load More")
                        .font(Font.custom("Nunito-Bold", size: 14))
                        .padding(5)
                        .foregroundStyle(Color.text)
                }
            }
        }
    }
}

#Preview {
    LoadMoreButton()
        .environmentObject(MedicineListViewModel())
}
