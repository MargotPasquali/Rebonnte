import SwiftUI

struct AisleListView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: AisleListViewModel
    @State private var showAddNewMedicineView = false

    // MARK: - View
    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                if viewModel.isLoading {
                    CustomLoadingView()
                        .accessibilityLabel("Chargement en cours")
                } else if viewModel.aisles.isEmpty {
                    Text("Aucun rayon disponible")
                        .font(.custom("Nunito-Medium", size: 16))
                        .foregroundStyle(Color.text)
                        .accessibilityLabel("Aucun rayon disponible")
                } else {
                    VStack {
                        Text("Aisles")
                            .font(.custom("Righteous", size: 30))
                            .foregroundStyle(Color.text)
                            .accessibilityLabel("Rayons")

                        ForEach(viewModel.aisles, id: \.self) { aisle in
                            NavigationLink(destination: MedicineListView(aisle: aisle)) {
                                AisleRowView(aisle: aisle)
                            }
                            .accessibilityLabel("Rayon \(aisle), bouton")
                        }
                        Spacer()
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
                    await viewModel.fetchAisles()
                }
            }) {
                AddNewMedicineView(viewModel: AddNewMedicineViewModel())
                    .environmentObject(SessionStore())
            }
        }
        .task {
            await viewModel.fetchAisles()
        }
    }
}

#Preview {
    AisleListView(viewModel: AisleListViewModel())
}
