import SwiftUI

//struct MedicineListView: View {
//    // MARK: - Properties
//    @ObservedObject var viewModel = MedicineListViewModel()
//    var aisle: String
//
//    // MARK: - View
//    var body: some View {
//        ZStack {
//            Color.background
//                .ignoresSafeArea()
//            ScrollView {
//                VStack {
//                    ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
//                        NavigationLink(destination: MedicineDetailView(medicine: medicine, viewModel: MedicineDetailViewModel())) {
//                            MedicineListRowView(medicine: medicine)
//                        }
//                        .accessibilityLabel("Médicament \(medicine.name), stock \(medicine.stock), dans l’allée \(aisle), bouton")
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text(aisle)
//                        .font(.custom("Nunito-Bold", size: 18))
//                        .foregroundStyle(Color.text)
//                        .accessibilityLabel("Allée \(aisle)")
//                }
//            }
//            .onAppear {
//                Task {
//                    await viewModel.fetchMedicines()
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    MedicineListView(aisle: "Aisle 1").environmentObject(SessionStore())
//}

struct MedicineListView: View {
    @ObservedObject var viewModel = MedicineListViewModel()
    var aisle: String

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            ScrollView {
                VStack {
                    ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
                        NavigationLink(destination: MedicineDetailView(medicine: medicine, viewModel: MedicineDetailViewModel())) {
                            MedicineListRowView(medicine: medicine)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(aisle)
                        .font(.custom("Nunito-Bold", size: 18))
                        .foregroundStyle(Color.text)
                }
            }
            .onAppear { viewModel.startObserving() }
            .onDisappear { viewModel.stopObserving() }
        }
    }
}
