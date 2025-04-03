//
//  AddNewMedicineView.swift
//  MediStock
//
//  Created by Margot Pasquali on 02/04/2025.
//

import SwiftUI

struct AddNewMedicineView: View {

    @ObservedObject var viewModel: AddNewMedicineViewModel
    private var stockBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(viewModel.stock) },
            set: { viewModel.stock = Int($0) }
        )
    }
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                VStack {
                    Image(systemName: "pills.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .symbolRenderingMode(.palette).foregroundStyle(.action, .text)
                        .padding(.top, 20.0)
                    TextField("", text: $viewModel.name, prompt: Text("Name").foregroundColor(.gray))
                        .font(.custom("Righteous", size: 25))
                        .foregroundStyle(Color.text)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                        .padding(.bottom)

                    HStack {
                        Section {
                            Text("Stock")
                                .font(.custom("Nunito-Bold", size: 18))
                                .foregroundStyle(Color.background)
                                .padding(.trailing)
                            Slider(value: stockBinding, in: 0...100, step: 5) {
                                Text("Stock: \(viewModel.stock, specifier: "%.0f")")
                            }
                            .tint(viewModel.stock < 50 ? .alert : .success)
                            Text("\(viewModel.stock)")
                                .font(.custom("Nunito-Bold", size: 16))
                                .foregroundStyle(Color.background)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                    }.padding()
                        .background(Color.text)
                        .cornerRadius(4)

                    HStack {
                        Section {
                            Text("Aisle")
                                .font(.custom("Nunito-Bold", size: 18))
                                .foregroundStyle(Color.background)
                                .padding(.trailing)
                            TextField("", text: $viewModel.aisle, prompt: Text("0").foregroundColor(.gray))
                                .font(.custom("Nunito-Bold", size: 18))
                                .foregroundStyle(Color.background)
                                .multilineTextAlignment(.leading)

                        }

                    }.padding()
                        .background(Color.text)
                        .cornerRadius(4)

                    Spacer()

                    Button(action: {
                        Task {
                            await viewModel.addNewMedecine()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("Create")
                                .foregroundColor(.white)
                                .font(Font.custom("Nunito-ExtraBold", size: 18))
                                .fontWeight(.bold)
                        }
                    }
                    .frame(width: 100)
                    .padding()
                    .background(Color.action)
                    .cornerRadius(8)
                    .disabled(viewModel.isLoading)
                    .padding(.top, 20)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
            }.toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Add a new medicine")
                            .foregroundStyle(Color.text)
                            .font(Font.custom("Righteous", size: 30))
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AddNewMedicineView(viewModel: AddNewMedicineViewModel())
}
