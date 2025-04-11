import SwiftUI

struct AllMedicinesView: View {
    // MARK: - Properties
    @ObservedObject var viewModel = MedicineListViewModel()
    @State private var showAddNewMedicineView = false

    // MARK: - Constants
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - View
    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Text("All Medicines")
                        .font(.custom("Righteous", size: 30))
                        .foregroundStyle(Color.text)
                        .accessibilityLabel("Tous les médicaments")
                        .padding(.bottom, 10)

                    HStack {
                        CustomSearchBar(viewModel: viewModel)
                            .accessibilityLabel("Rechercher un médicament")

                        Spacer()

                        Picker("Sort by", selection: $viewModel.sortOption) {
                            Text("None").tag(SortOption.none)
                            Text("Name").tag(SortOption.name)
                            Text("Stock").tag(SortOption.stock)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.trailing, 10)
                        .accessibilityLabel("Trier par")
                    }
                    .padding(.bottom, 10)

                    if viewModel.isLoading {
                        CustomLoadingView()
                            .accessibilityLabel("Chargement en cours")
                            .frame(maxHeight: .infinity)
                    } else if viewModel.filteredMedicines.isEmpty {
                        Text("No medicines found")
                            .font(.custom("Nunito-Medium", size: 16))
                            .foregroundStyle(Color.text)
                            .accessibilityLabel("Aucun médicament trouvé")
                            .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.filteredMedicines, id: \.id) { medicine in
                                    NavigationLink(destination: MedicineDetailView(medicine: medicine, viewModel: MedicineDetailViewModel())) {
                                        MedicineRowView(medicine: medicine)
                                    }
                                    .accessibilityLabel("Médicament \(medicine.name), stock \(medicine.stock)\(medicine.stock <= 40 ? ", faible stock" : ""), bouton")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                    }
                }
                .navigationBarItems(trailing: Button(action: {
                    showAddNewMedicineView = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.action)
                        .accessibilityLabel("Ajouter un nouveau médicament")
                })
                .sheet(isPresented: $showAddNewMedicineView, onDismiss: {
                    Task {
                        await viewModel.fetchMedicines()
                    }
                }) {
                    AddNewMedicineView(viewModel: AddNewMedicineViewModel())
                        .environmentObject(SessionStore())
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchMedicines()
                }
            }
            .onChange(of: viewModel.sortOption) { newSortOption in
                Task {
                    if newSortOption == .name {
                        await viewModel.fetchMedicinesSortedByName()
                    } else if newSortOption == .stock {
                        await viewModel.fetchMedicinesSortedByStock()
                    } else {
                        await viewModel.fetchMedicines()
                    }
                }
            }
        }
    }
}

#Preview {
    AllMedicinesView()
}
