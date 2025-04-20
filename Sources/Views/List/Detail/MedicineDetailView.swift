import SwiftUI
//
//struct MedicineDetailView: View {
//    // MARK: - Constants
//    private let lowStockThreshold = 40
//
//    // MARK: - Properties
//    @State var medicine: Medicine
//    @State private var initialMedicine: Medicine
//    @ObservedObject var viewModel = MedicineDetailViewModel()
//    @EnvironmentObject var session: SessionStore
//    @Environment(\.dismiss) private var dismiss
//    @State private var showDeleteConfirmation = false
//    @State private var showErrorAlert = false
//
//    // MARK: - Init
//    init(medicine: Medicine, viewModel: MedicineDetailViewModel) {
//        self._medicine = State(initialValue: medicine)
//        self._initialMedicine = State(initialValue: medicine)
//        self.viewModel = viewModel
//    }
//
//    private var stockStatusColor: Color {
//        medicine.stock <= lowStockThreshold ? .alert : .success
//    }
//
//    private var stockBinding: Binding<Double> {
//        Binding<Double>(
//            get: { Double(medicine.stock) },
//            set: { medicine.stock = Int($0) }
//        )
//    }
//    // MARK: - View
//    var body: some View {
//        ZStack {
//            Color.background
//                .ignoresSafeArea()
//            ScrollView {
//                VStack(alignment: .leading, spacing: 10) {
//                    MedicineDetailHeaderView(
//                        stockStatusColor: stockStatusColor,
//                        isLowStock: medicine.stock <= lowStockThreshold,
//                        medicineName: $medicine.name
//                    )
//
//                    MedicineDetailStockSection(
//                        stockStatusColor: stockStatusColor,
//                        stock: stockBinding
//                    )
//
//                    MedicineDetailAisleSection(aisle: $medicine.aisle)
//
//                    MedicineDetailHistorySection(
//                        history: viewModel.history,
//                        medicineId: medicine.id
//                    )
//                }
//                .padding()
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Medicine Details")
//                        .font(.custom("Nunito-Bold", size: 18))
//                        .foregroundStyle(Color.text)
//                        .accessibilityLabel("Détails du médicament")
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        Task {
//                            var changes: [MedecineChangeRequest] = []
//                            if medicine.name != initialMedicine.name {
//                                changes.append(.nameChanged)
//                            }
//                            if medicine.stock != initialMedicine.stock {
//                                changes.append(.stockChanged)
//                            }
//                            if medicine.aisle != initialMedicine.aisle {
//                                changes.append(.aisleChanged)
//                            }
//
//                            await viewModel.modifyMedicine(medicine, user: session.session?.id ?? "", changes: changes)
//                            dismiss()
//                        }
//                    }) {
//                        Image(systemName: "checkmark.square.fill")
//                            .resizable()
//                            .frame(width: 25, height: 25)
//                            .symbolRenderingMode(.palette)
//                            .foregroundStyle(.success, .text)
//                            .accessibilityLabel("Valider les modifications")
//                    }
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        showDeleteConfirmation = true
//                    }) {
//                        Image(systemName: "trash")
//                            .foregroundStyle(Color.alert)
//                            .accessibilityLabel("Supprimer le médicament")
//                    }
//                }
//            }
//            .alert("Delete Medicine", isPresented: $showDeleteConfirmation) {
//                Button("Cancel", role: .cancel) { }
//                    .accessibilityLabel("Annuler")
//                Button("Delete", role: .destructive) {
//                    Task {
//                        guard medicine.id != nil else {
//                            viewModel.errorMessage = "Cannot delete medicine: Invalid ID."
//                            showErrorAlert = true
//                            return
//                        }
//
//                        if let index = viewModel.medicines.firstIndex(where: { $0.id == medicine.id }) {
//                            await viewModel.deleteMedicines(at: IndexSet(integer: index))
//                            if viewModel.errorMessage == nil {
//                                dismiss()
//                            } else {
//                                showErrorAlert = true
//                            }
//                        } else {
//                            viewModel.errorMessage = "Medicine not found in the list."
//                            showErrorAlert = true
//                        }
//                    }
//                }
//                .accessibilityLabel("Confirmer la suppression")
//            } message: {
//                Text("Are you sure you want to delete \(medicine.name)? This action cannot be undone.")
//                    .accessibilityLabel("Voulez-vous vraiment supprimer \(medicine.name) ? Cette action est irréversible.")
//            }
//            .alert("Error", isPresented: $showErrorAlert) {
//                Button("OK", role: .cancel) { }
//                    .accessibilityLabel("OK")
//            } message: {
//                Text(viewModel.errorMessage ?? "An unknown error occurred.")
//                    .accessibilityLabel("Erreur : \(viewModel.errorMessage ?? "Une erreur inconnue s’est produite.")")
//            }
//            .onAppear {
//                Task {
//                    await viewModel.fetchMedicines()
//                    await viewModel.fetchHistory(for: medicine)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    let sampleMedicine = Medicine(name: "Aspirin", stock: 100, aisle: "1")
//    let sampleViewModel = MedicineDetailViewModel()
//    MedicineDetailView(medicine: sampleMedicine, viewModel: sampleViewModel)
//        .environmentObject(SessionStore())
//}

struct MedicineDetailView: View {
    @State var medicine: Medicine
    @State private var initialMedicine: Medicine
    @ObservedObject var viewModel: MedicineDetailViewModel
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showErrorAlert = false

    init(medicine: Medicine, viewModel: MedicineDetailViewModel) {
        self._medicine = State(initialValue: medicine)
        self._initialMedicine = State(initialValue: medicine)
        self.viewModel = viewModel
    }

    private var stockStatusColor: Color { medicine.stock <= 40 ? .alert : .success }
    private var stockBinding: Binding<Double> {
        Binding<Double>(get: { Double(medicine.stock) }, set: { medicine.stock = Int($0) })
    }

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    MedicineDetailHeaderView(stockStatusColor: stockStatusColor, isLowStock: medicine.stock <= 40, medicineName: $medicine.name)
                    MedicineDetailStockSection(stockStatusColor: stockStatusColor, stock: stockBinding)
                    MedicineDetailAisleSection(aisle: $medicine.aisle)
                    MedicineDetailHistorySection(history: viewModel.history, medicineId: medicine.id)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Medicine Details")
                        .font(.custom("Nunito-Bold", size: 18))
                        .foregroundStyle(Color.text)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            var changes: [MedecineChangeRequest] = []
                            if medicine.name != initialMedicine.name { changes.append(.nameChanged) }
                            if medicine.stock != initialMedicine.stock { changes.append(.stockChanged) }
                            if medicine.aisle != initialMedicine.aisle { changes.append(.aisleChanged) }
                            await viewModel.modifyMedicine(medicine, user: session.session?.id ?? "", changes: changes)
                            dismiss()
                        }
                    }) {
                        Image(systemName: "checkmark.square.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.success, .text)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash").foregroundStyle(Color.alert)
                    }
                }
            }
            .alert("Delete Medicine", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        if let index = viewModel.medicines.firstIndex(where: { $0.id == medicine.id }) {
                            await viewModel.deleteMedicines(at: IndexSet(integer: index))
                            if viewModel.errorMessage == nil { dismiss() } else { showErrorAlert = true }
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete \(medicine.name)? This action cannot be undone.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Une erreur inconnue s’est produite.")
            }
            .onAppear {
                viewModel.startObservingMedicines()
                viewModel.observeHistory(for: medicine)
            }
            .onDisappear { viewModel.stopObserving() }
        }
    }
}
