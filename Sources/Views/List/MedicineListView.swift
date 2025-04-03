import SwiftUI

struct MedicineListView: View {
    @ObservedObject var viewModel = MedicineListViewModel()
    var aisle: String

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
                        NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
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
            .onAppear {
                Task {
                    await viewModel.fetchMedicines()
                }
            }
        }
    }
}

#Preview {
    MedicineListView(aisle: "Aisle 1").environmentObject(SessionStore())
}
