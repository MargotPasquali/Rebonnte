import SwiftUI

struct MedicineListRowView: View {
    // MARK: - Constants
    let medicine: Medicine

    private let lowStockThreshold = 40

    // MARK: - Properties
    private var stockStatusColor: Color {
        medicine.stock <= lowStockThreshold ? .alert : .success
    }

    // MARK: - View
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .foregroundStyle(Color.text)

            HStack {
                Image(systemName: "pills.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(stockStatusColor)
                    .opacity(medicine.stock <= lowStockThreshold ? 1.0 : 0.3)
                    .padding(.trailing, 15.0)
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    Text(medicine.name)
                        .font(Font.custom("Nunito-SemiBold", size: 18))
                        .foregroundStyle(Color.background)

                    Text("Stock: \(medicine.stock)")
                        .font(Font.custom("Nunito-Medium", size: 14))
                        .foregroundStyle(Color.background)
                }
                Spacer()
            }
            .padding(.leading, 15.0)
        }
        .accessibilityLabel("\(medicine.name), stock \(medicine.stock)\(medicine.stock <= lowStockThreshold ? ", faible stock" : ""), bouton")

    }
}

#Preview {
    let sampleMedicine = Medicine(name: "Aspirin", stock: 5, aisle: "A1")
    return MedicineListRowView(medicine: sampleMedicine)
}
