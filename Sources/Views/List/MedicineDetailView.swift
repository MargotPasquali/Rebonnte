import SwiftUI

struct MedicineDetailView: View {
    @State var medicine: Medicine
    @State private var initialMedicine: Medicine
    @ObservedObject var viewModel = MedicineDetailViewModel()
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showErrorAlert = false
    private let lowStockThreshold = 40

    init(medicine: Medicine, viewModel: MedicineDetailViewModel) {
        self._medicine = State(initialValue: medicine)
        self._initialMedicine = State(initialValue: medicine)
        self.viewModel = viewModel
    }

    private var stockStatusColor: Color {
        medicine.stock <= lowStockThreshold ? .alert : .success
    }
    private var stockBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(medicine.stock) },
            set: { medicine.stock = Int($0) }
        )
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "pills.circle.fill")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(stockStatusColor.opacity(medicine.stock <= lowStockThreshold ? 1.0 : 0.5), .text)
                            // Title
                            TextField("Name", text: $medicine.name)
                                .font(.custom("Righteous", size: 30))
                                .foregroundStyle(Color.text)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 300)
                                .padding(.bottom, 10)
                                .autocorrectionDisabled(true)
                        }
                        Spacer()
                    }

                    // Medicine Stock
                    medicineStockSection

                    // Medicine Aisle
                    medicineAisleSection

                    // History Section
                    if viewModel.history.isEmpty {
                        Text("No history available")
                            .font(.custom("Nunito-Medium", size: 18))
                            .foregroundStyle(Color.background)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.text)
                            .cornerRadius(4)
                    } else {
                        historySection
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Titre centré
                ToolbarItem(placement: .principal) {
                    Text("Medicine Details")
                        .font(.custom("Nunito-Bold", size: 18))
                        .foregroundStyle(Color.text)
                }
                // Bouton "Modifier" à gauche
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            var changes: [MedecineChangeRequest] = []
                            if medicine.name != initialMedicine.name {
                                changes.append(.nameChanged)
                            }
                            if medicine.stock != initialMedicine.stock {
                                changes.append(.stockChanged)
                            }
                            if medicine.aisle != initialMedicine.aisle {
                                changes.append(.aisleChanged)
                            }

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
                // Bouton "Supprimer" à droite
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.alert)
                    }
                }
            }
            .alert("Delete Medicine", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        guard medicine.id != nil else {
                            viewModel.errorMessage = "Cannot delete medicine: Invalid ID."
                            showErrorAlert = true
                            return
                        }

                        if let index = viewModel.medicines.firstIndex(where: { $0.id == medicine.id }) {
                            await viewModel.deleteMedicines(at: IndexSet(integer: index))
                            if viewModel.errorMessage == nil {
                                dismiss()
                            } else {
                                showErrorAlert = true
                            }
                        } else {
                            viewModel.errorMessage = "Medicine not found in the list."
                            showErrorAlert = true
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete \(medicine.name)? This action cannot be undone.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            }
            .onAppear {
                Task {
                    await viewModel.fetchMedicines()
                    await viewModel.fetchHistory(for: medicine)
                }
            }
        }
    }
}

extension MedicineDetailView {
    private var medicineStockSection: some View {
        HStack {
            Text("Stock")
                .font(.custom("Nunito-Bold", size: 18))
                .foregroundStyle(Color.background)
                .padding(.trailing)
            Slider(value: stockBinding, in: 0...100, step: 5) {
                Text("Stock: \(medicine.stock, specifier: "%.0f")")
            }
            .tint(medicine.stock < 50 ? .alert : .success)
            Text("\(medicine.stock)")
                .font(.custom("Nunito-Bold", size: 16))
                .foregroundStyle(Color.background)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.text)
        .cornerRadius(4)
    }

    private var medicineAisleSection: some View {
        HStack {
            Text("Aisle")
                .font(.custom("Nunito-Bold", size: 18))
                .foregroundStyle(Color.background)
                .padding(.trailing)
            TextField("", text: $medicine.aisle, prompt: Text("0").foregroundColor(.gray))
                .font(.custom("Nunito-Bold", size: 18))
                .foregroundStyle(Color.background)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.text)
        .cornerRadius(4)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("History")
                .font(.custom("Nunito-Bold", size: 18))
                .foregroundStyle(Color.background)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.history.filter { $0.medicineId == medicine.id }, id: \.id) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.action)
                        .font(.custom("Nunito-SemiBold", size: 16))
                        .foregroundStyle(Color.background)
                    Text("User: \(entry.fullName)")
                        .font(.custom("Nunito-Regular", size: 16))
                        .foregroundStyle(Color.background)
                    Text("Date: \(entry.timestamp.formatted())")
                        .font(.custom("Nunito-Light", size: 16))
                        .foregroundStyle(Color.background)
                    Text("Details: \(entry.details)")
                        .font(.custom("Nunito-ExtraLight", size: 16))
                        .foregroundStyle(Color.background)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.text)
        .cornerRadius(4)
    }
}

#Preview {
    let sampleMedicine = Medicine(name: "Aspirin", stock: 100, aisle: "1")
    let sampleViewModel = MedicineDetailViewModel()
    MedicineDetailView(medicine: sampleMedicine, viewModel: sampleViewModel)
        .environmentObject(SessionStore())
}
