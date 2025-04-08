import SwiftUI

struct AisleListView: View {
    @ObservedObject var viewModel: AisleListViewModel
    @State private var showAddNewMedicineView = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                if viewModel.isLoading {
                    CustomLoadingView()
                } else if viewModel.aisles.isEmpty {
                    Text("Aucun rayon disponible")
                        .font(.custom("Nunito-Medium", size: 16))
                        .foregroundStyle(Color.text)
                } else {
                    VStack {
                        Text("Aisles")
                            .font(.custom("Righteous", size: 30))
                            .foregroundStyle(Color.text)
                        ForEach(viewModel.aisles, id: \.self) { aisle in
                            NavigationLink(destination: MedicineListView(aisle: aisle)) {
                                AisleRowView(aisle: aisle)
                            }
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
            })
            .sheet(isPresented: $showAddNewMedicineView, onDismiss: {
                // Rafraîchir les allées après la fermeture de la feuille
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
