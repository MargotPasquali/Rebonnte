import SwiftUI

struct AllMedicinesView: View {
    @ObservedObject var viewModel = MedicineListViewModel()
    @State private var showAddNewMedicineView = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()

                VStack {
                    // Titre personnalisé
                    Text("All Medicines")
                        .font(.custom("Righteous", size: 30))
                        .foregroundStyle(Color.text)

                    // Filtrage et Tri
                    HStack {
                        CustomSearchBar(viewModel: viewModel)

                        Spacer()

                        Picker("Sort by", selection: $viewModel.sortOption) {
                            Text("None").tag(SortOption.none)
                            Text("Name").tag(SortOption.name)
                            Text("Stock").tag(SortOption.stock)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.trailing, 10)
                    }
                    .padding(.top, 10)

                    // Liste des Médicaments
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredMedicines, id: \.id) { medicine in
                                NavigationLink(destination: MedicineDetailView(medicine: medicine, viewModel: MedicineDetailViewModel())) {
                                    MedicineRowView(medicine: medicine)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
                .navigationBarItems(trailing: Button(action: {
                    showAddNewMedicineView = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.action)
                })
                .sheet(isPresented: $showAddNewMedicineView) {
                    AddNewMedicineView(viewModel: AddNewMedicineViewModel())
                        .environmentObject(SessionStore())
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchMedicines()
                }
            }
        }
    }
}

#Preview {
    AllMedicinesView()
}
